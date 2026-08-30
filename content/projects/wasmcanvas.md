---
title: wasmcanvas
layout: project
dataKey: wasmcanvas
---

A high-performance SQLite database viewer that renders query results directly to an HTML5 canvas using WebAssembly.

## Features

- 🚀 **Pure client-side SQLite** - Query 300k+ rows entirely in the browser
- 🎨 **Canvas rendering** - High-performance table visualization
- 🔍 **Search & Filter** - Real-time search across all columns
- 📄 **Pagination** - Navigate large datasets efficiently
- 🌙 **Modern UI** - Beautiful dark mode with glassmorphism effects
- ⚡ **Zero CGO** - Uses modernc.org/sqlite for cross-platform compatibility

## Quick Start

### Prerequisites

- Go 1.21 or later
- A modern web browser (Chrome, Firefox, Safari, Edge)
- (Optional) [Mage](https://magefile.org/) for automated builds

### Using Mage (Recommended)

```bash
# Install mage if you don't have it
go install github.com/magefile/mage@latest

# Build and launch (uses random IPv6 port, auto-opens Chrome)
mage launch
```

The `launch` command will:
- Build the WASM module automatically
- Start server on randomized port (8000-9999)
- Use IPv6 localhost (::1) to avoid port conflicts
- Log the exact URL: `http://[::1]:XXXX`
- Automatically open Chrome browser

### Manual Build & Run

1. Build the WASM module:
```bash
./build.sh
```

2. Start the development server:
```bash
go run cmd/serve/main.go

# Or with custom host/port:
go run cmd/serve/main.go -host ::1 -port 8888
```

3. Open your browser to:
```
http://localhost:8080
```

## Project Structure

```
wasmcanvas/
├── cmd/
│   ├── wasm/          # Go WASM module
│   │   └── main.go    # SQLite + canvas rendering
│   └── serve/         # Development server
│       └── main.go
├── web/
│   ├── index.html     # Main HTML interface
│   └── static/
│       ├── app.js     # JavaScript bridge
│       ├── styles.css # UI styling
│       ├── main.wasm  # Compiled WASM (generated)
│       └── wasm_exec.js # Go WASM runtime (generated)
├── build.sh           # Build script
└── go.mod
```

## How It Works

1. **Database Loading**: The SQLite database is downloaded to the browser and loaded into WASM's virtual filesystem
2. **Query Execution**: Go code running as WASM executes SQL queries using modernc.org/sqlite
3. **Canvas Rendering**: Results are rendered directly to an HTML5 canvas for optimal performance
4. **Interactivity**: JavaScript handles UI controls and bridges communication with WASM

## Database Schema

The `Index.sqlite` database contains file system metadata in table `tb0`:

- `path` - File path
- `name` - File name
- `size` - File size
- `extension` - File extension
- `mod_time` - Modification time
- `create_time` - Creation time
- `permissions` - File permissions
- `is_dir` - Directory flag
- `mime_type` - MIME type

## Performance

- **Database size**: ~89MB
- **Total rows**: 317,000
- **Query time**: <100ms (client-side)
- **Rendering**: 60fps smooth scrolling
- **Memory usage**: ~150-200MB

## Browser Compatibility

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 15+
- ✅ Edge 90+

## Development

### Rebuild WASM

```bash
./build.sh
```

### Run Development Server

```bash
go run cmd/serve/main.go
```

### Debug

Open browser DevTools Console to see WASM logs and errors.

## Technology Stack

- **Go 1.21+** - WASM compilation
- **modernc.org/sqlite** - CGO-free SQLite
- **HTML5 Canvas** - High-performance rendering
- **Vanilla JavaScript** - No framework dependencies
- **Inter Font** - Modern typography

## License

MIT

## Credits

Built with ❤️ using Go WebAssembly and modernc.org/sqlite
