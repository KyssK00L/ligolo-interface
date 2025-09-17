# ligolo-interface

Utility script for creating a dedicated TUN interface from a JSON file
describing the routes to advertise to Ligolo. It can also generate a sample
configuration and remove an existing interface.

## Prerequisites

- bash
- [jq](https://jqlang.github.io/jq/) for reading JSON files
- Root privileges to manage network interfaces

## Usage

```bash
sudo ./ligolo-interface.sh [options] <file>.json
```

Available options:

- `-g`, `--gen-example`: generates a ready-to-use `example_interface.json`
  file.
- `-c`, `--clean`: removes the interface derived from the JSON file name.
- `--user <name>`: sets the UNIX owner of the TUN interface (defaults to
  `kali`).

The name of the created interface matches the JSON file name without the
extension. Each element of the JSON array must be a route in CIDR format.

## Example

```bash
# Generate an example
./ligolo-interface.sh --gen-example

# Create an interface from a file
sudo ./ligolo-interface.sh routes.json

# Remove the created interface
sudo ./ligolo-interface.sh --clean routes.json
```
