import json, struct, math

def get_glb_data(filepath):
    with open(filepath, 'rb') as f:
        f.read(12)
        chunk_len = struct.unpack('<I', f.read(4))[0]
        f.read(4)
        return json.loads(f.read(chunk_len).decode('utf-8'))

gltf = get_glb_data('WEBSITE 2/assets/macbook.glb')
nodes = gltf.get('nodes', [])
for i, n in enumerate(nodes):
    nm = n.get('name', '')
    if 'VCQqxpxkUlzqcJI' in nm or 'BoBvWqDHZjAeVrp' in nm:
        print(f"Node {i}: {nm}")
        print(f"  rotation: {n.get('rotation', [0,0,0,1])}")
        print(f"  translation: {n.get('translation', [0,0,0])}")
