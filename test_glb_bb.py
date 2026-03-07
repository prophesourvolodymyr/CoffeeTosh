import struct, json
def get_glb_data(filepath):
    with open(filepath, 'rb') as f:
        f.read(12)
        chunk_len = struct.unpack('<I', f.read(4))[0]
        f.read(4)
        return json.loads(f.read(chunk_len).decode('utf-8'))

gltf = get_glb_data('WEBSITE 2/assets/macbook.glb')
accs = gltf.get('accessors', [])
for n in gltf.get('nodes', []):
    nm = n.get('name', '')
    if 'VCQqxpxkUlzqcJI' in nm or 'BoBvWqDHZjAeVrp' in nm:
        print(f"Node: {nm}")
        mesh_idx = n.get('mesh')
        if mesh_idx is not None:
            mesh = gltf['meshes'][mesh_idx]
            for p in mesh.get('primitives', []):
                pos_acc = p['attributes'].get('POSITION')
                if pos_acc is not None:
                    a = accs[pos_acc]
                    print(f"  min: {a.get('min')}")
                    print(f"  max: {a.get('max')}")
