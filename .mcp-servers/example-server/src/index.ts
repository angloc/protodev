#!/usr/bin/env node
/**
 * Example MCP Server for the protodev dev container
 *
 * This server demonstrates MCP capabilities and provides useful tools
 * that leverage the dev container environment (Docker-in-Docker, Python, etc.)
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { exec } from "child_process";
import { promisify } from "util";
import * as fs from "fs/promises";
import * as path from "path";

const execAsync = promisify(exec);

class ExampleServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "example-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupResourceHandlers();
    this.setupToolHandlers();

    // Error handling
    this.server.onerror = (error) => console.error("[MCP Error]", error);
    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  private setupResourceHandlers() {
    // List available resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => ({
      resources: [
        {
          uri: "container://info",
          name: "Container Information",
          mimeType: "application/json",
          description:
            "Information about the dev container environment including available tools",
        },
        {
          uri: "workspace://structure",
          name: "Workspace Structure",
          mimeType: "application/json",
          description: "Directory structure of the /workspace folder",
        },
      ],
    }));

    // Read resource content
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const uri = request.params.uri;

      if (uri === "container://info") {
        const info = await this.getContainerInfo();
        return {
          contents: [
            {
              uri,
              mimeType: "application/json",
              text: JSON.stringify(info, null, 2),
            },
          ],
        };
      }

      if (uri === "workspace://structure") {
        const structure = await this.getWorkspaceStructure();
        return {
          contents: [
            {
              uri,
              mimeType: "application/json",
              text: JSON.stringify(structure, null, 2),
            },
          ],
        };
      }

      throw new McpError(ErrorCode.InvalidRequest, `Unknown resource: ${uri}`);
    });
  }

  private setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "docker_ps",
          description:
            "List running Docker containers (uses Docker-in-Docker)",
          inputSchema: {
            type: "object",
            properties: {
              all: {
                type: "boolean",
                description: "Show all containers (default shows just running)",
              },
            },
          },
        },
        {
          name: "run_python",
          description: "Execute a Python script or expression",
          inputSchema: {
            type: "object",
            properties: {
              code: {
                type: "string",
                description: "Python code to execute",
              },
            },
            required: ["code"],
          },
        },
        {
          name: "list_projects",
          description: "List all projects in the /workspace/projects directory",
          inputSchema: {
            type: "object",
            properties: {},
          },
        },
        {
          name: "check_tool",
          description: "Check if a tool is available in the container",
          inputSchema: {
            type: "object",
            properties: {
              tool: {
                type: "string",
                description:
                  "Name of the tool to check (e.g., docker, python, node)",
              },
            },
            required: ["tool"],
          },
        },
      ],
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "docker_ps":
            return await this.dockerPs(args?.all as boolean);
          case "run_python":
            return await this.runPython(args?.code as string);
          case "list_projects":
            return await this.listProjects();
          case "check_tool":
            return await this.checkTool(args?.tool as string);
          default:
            throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
        }
      } catch (error) {
        if (error instanceof McpError) throw error;
        return {
          content: [
            {
              type: "text",
              text: `Error: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  // Tool implementations

  private async dockerPs(all?: boolean) {
    const flag = all ? "-a" : "";
    try {
      const { stdout } = await execAsync(`docker ps ${flag} --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"`);
      return {
        content: [{ type: "text", text: stdout || "No containers found" }],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `Docker error: ${error instanceof Error ? error.message : String(error)}\nIs Docker daemon running?`,
          },
        ],
        isError: true,
      };
    }
  }

  private async runPython(code: string) {
    if (!code) {
      throw new McpError(ErrorCode.InvalidParams, "Code is required");
    }

    try {
      // Use python3 -c for simple expressions
      const { stdout, stderr } = await execAsync(`python3 -c "${code.replace(/"/g, '\\"')}"`);
      return {
        content: [
          {
            type: "text",
            text: stdout || stderr || "(no output)",
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `Python error: ${error instanceof Error ? error.message : String(error)}`,
          },
        ],
        isError: true,
      };
    }
  }

  private async listProjects() {
    const projectsDir = "/workspace/projects";
    try {
      const entries = await fs.readdir(projectsDir, { withFileTypes: true });
      const projects = entries
        .filter((e) => e.isDirectory())
        .map((e) => e.name);

      if (projects.length === 0) {
        return {
          content: [{ type: "text", text: "No projects found in /workspace/projects" }],
        };
      }

      return {
        content: [
          {
            type: "text",
            text: `Projects:\n${projects.map((p) => `  - ${p}`).join("\n")}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `Error listing projects: ${error instanceof Error ? error.message : String(error)}`,
          },
        ],
        isError: true,
      };
    }
  }

  private async checkTool(tool: string) {
    if (!tool) {
      throw new McpError(ErrorCode.InvalidParams, "Tool name is required");
    }

    try {
      const { stdout } = await execAsync(`which ${tool}`);
      const { stdout: version } = await execAsync(`${tool} --version 2>&1 || true`).catch(() => ({ stdout: "version unknown" }));

      return {
        content: [
          {
            type: "text",
            text: `✓ ${tool} is available\n  Path: ${stdout.trim()}\n  Version: ${version.trim().split("\n")[0]}`,
          },
        ],
      };
    } catch {
      return {
        content: [
          {
            type: "text",
            text: `✗ ${tool} is not available in this container`,
          },
        ],
      };
    }
  }

  // Resource helpers

  private async getContainerInfo() {
    const tools = ["docker", "python3", "node", "npm", "pnpm", "bun", "git", "gh"];
    const available: Record<string, string> = {};

    for (const tool of tools) {
      try {
        const { stdout } = await execAsync(`which ${tool}`);
        available[tool] = stdout.trim();
      } catch {
        // Tool not available
      }
    }

    return {
      hostname: process.env.HOSTNAME || "unknown",
      user: process.env.USER || "unknown",
      workdir: process.cwd(),
      node_version: process.version,
      available_tools: available,
      env: {
        DISPLAY: process.env.DISPLAY,
        DOCKER_HOST: process.env.DOCKER_HOST,
      },
    };
  }

  private async getWorkspaceStructure() {
    const workspace = "/workspace";
    const structure: Record<string, string[]> = {};

    try {
      const entries = await fs.readdir(workspace, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.isDirectory() && !entry.name.startsWith(".")) {
          try {
            const subEntries = await fs.readdir(path.join(workspace, entry.name));
            structure[entry.name] = subEntries.slice(0, 10); // Limit to first 10
          } catch {
            structure[entry.name] = ["(access denied)"];
          }
        }
      }
    } catch (error) {
      return { error: String(error) };
    }

    return structure;
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Example MCP server running on stdio");
  }
}

const server = new ExampleServer();
server.run().catch(console.error);
