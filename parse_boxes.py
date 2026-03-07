import json

with open('WEBSITE 2/assets/macbook.glb', 'rb') as f:
    f.read(12)
    import struct
    l = struct.unpack('<I', f.read(4))[0]
    f.read(4)
    gltf = json.loads(f.read(l).decode('utf-8'))

for i, n in enumerate(gltf.get('nodes', [])):
    nm = n.get('name', '')
    if 'VCQqxpxkUlzqcJI' in nm or 'BoBvWqDHZjAeVrp' in nm:
        print(f"Node: {nm}")
        t = n.get('translation', [0,0,0])
        print("  translation:", t)
