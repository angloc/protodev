# MCP Servers

This directory contains Model Context Protocol (MCP) servers that run inside the dev container and are accessible to Cline when VS Code is connected to the container.

## Directory Structure

```
.mcp-servers/
├── README.md           # This file
├── cline-config.json   # MCP server configuration for Cline
└── example-server/     # Example MCP server template
    ├── package.json
    ├── tsconfig.json
    └── src/
        └── index.ts
```

## How It Works

1. **MCP servers are built inside the container** during `postCreateCommand.sh`
2. **Cline reads the config** from `.mcp-servers/cline-config.json` (workspace-relative)
3. **Servers use container paths** - they can access Docker-in-Docker, Python, Node.js, etc.

## Creating a New MCP Server

### Option 1: Use the Template Generator

Inside the container, run:

```bash
cd /workspace/.mcp-servers
npx @modelcontextprotocol/create-server my-new-server
cd my-new-server
npm install
npm run build
```

### Option 2: Copy the Example Server

```bash
cp -r example-server my-new-server
cd my-new-server
# Edit src/index.ts
npm install
npm run build
```

### Option 3: Manual Setup

1. Create a new directory: `mkdir my-server && cd my-server`
2. Initialize: `npm init -y`
3. Install SDK: `npm install @modelcontextprotocol/sdk`
4. Create your server implementation

## Registering with Cline

After building your server, add it to `.mcp-servers/cline-config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/workspace/.mcp-servers/my-server/build/index.js"],
      "env": {
        "MY_API_KEY": "your-key-here"
      }
    }
  }
}
```

## Configuring Cline

For Cline to use the workspace MCP config, you need to set up your Cline settings to reference this file. The servers will be available when VS Code is connected to the dev container.

### Option A: Symlink (Recommended for Dev Container)

In your **host** Cline settings directory, create a symlink:

**Windows (PowerShell as Admin):**
```powershell
$clineDir = "$env:APPDATA\Code\User\globalStorage\saoudrizwan.claude-dev\settings"
New-Item -ItemType SymbolicLink -Path "$clineDir\cline_mcp_settings.json" -Target "C:\path\to\protodev\.mcp-servers\cline-config.json"
```

**Linux/Mac:**
```bash
ln -sf /path/to/protodev/.mcp-servers/cline-config.json ~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

### Option B: Manual Copy

Copy the config to Cline's settings location when you want to use these servers.

## Environment Variables

Sensitive values (API keys, tokens) should be stored in environment variables, not committed to the repo. Options:

1. **Use `.env` file** (gitignored) and load in `postCreateCommand.sh`
2. **Pass via docker-compose** environment section
3. **Use VS Code settings** for sensitive values

## Available Servers

| Server | Description | Status |
|--------|-------------|--------|
| example-server | Template server with tool and resource examples | Ready |

## Troubleshooting

### Server Not Connecting

1. Check the build path matches the config (usually `build/` or `dist/`)
2. Verify the server was built: `ls -la /workspace/.mcp-servers/my-server/build/`
3. Test manually: `node /workspace/.mcp-servers/my-server/build/index.js`

### Permission Denied

Ensure the build script made the file executable:
```bash
chmod +x /workspace/.mcp-servers/my-server/build/index.js
```

### Missing Dependencies

Rebuild the server:
```bash
cd /workspace/.mcp-servers/my-server
npm install
npm run build
```
