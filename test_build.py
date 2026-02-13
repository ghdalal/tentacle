import subprocess
import os
import sys

# Force output
sys.stdout.reconfigure(line_buffering=True)

def test_openscad_build():
    print("🚀 Testing OpenSCAD Artifact Generation...")
    
    # Define paths
    scad_file = "src/s33/main.scad" # Ensure this path matches your project
    output_dir = "output/prints/test_render"
    
    if not os.path.exists(scad_file):
        print(f"❌ ERROR: Cannot find {scad_file}")
        return

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"📁 Created directory: {output_dir}")

    # Trial command: Render just the ISO view
    output_file = os.path.join(output_dir, "iso_test.png")
    cmd = [
        "openscad",
        "-o", output_file,
        "--imgsize=1200,1200",
        "--viewall", "--autocenter",
        scad_file
    ]
    
    print(f"🔨 Executing: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode == 0:
            print(f"✅ SUCCESS: Render saved to {output_file}")
        else:
            print("❌ OPENSCAD ERROR:")
            print(result.stderr)
    except Exception as e:
        print(f"❌ SYSTEM ERROR: {str(e)}")

if __name__ == "__main__":
    test_openscad_build()