# Trepponti Bridge — OpenSCAD 3D Model

A parametric 3D model of **Trepponti Bridge (Ponte dei Trepponti)**, a historic landmark in Comacchio, Italy, created using OpenSCAD.

The model recreates the bridge's distinctive five-sided structure, arches, staircases, parapets, and central tower, with approximate dimensions derived from geographical measurements and visual references.

## Features

- Parametric 3D model written in OpenSCAD.
- Bridge body with a five-sided footprint.
- Five arches representing the bridge's characteristic structure.
- Mirrored staircases with individual steps and side parapets.
- Fan-shaped staircase module with widening steps.
- Central tower with an opening and pyramidal roof.
- Raised platform and perimeter parapets. 
- Stepped, seven-sided decorative relief.
- Dimensions based on measurements taken from Google Earth.
- Designed at **1:200 scale**.

## Repository Structure

```text
.
├── main.scad          # Main bridge model and assembly
├── body.scad          # Bridge body and arch geometry
├── stairs.scad        # Standard staircase module
├── fan_stairs.scad    # Widening/fan-shaped staircase module
├── tower.scad         # Tower and pyramidal roof
├── pedestal.scad      # Display pedestal / plinth
└── relief.scad        # Stepped decorative relief
```

## Requirements

- [OpenSCAD](https://openscad.org/)

## Usage

1. Clone or download this repository.
2. Open `main.scad` in OpenSCAD.
3. Render the model using **F6**.
4. Export the model using `File → Export → Export as STL` if you want to 3D print it.

The model is primarily controlled through parameters defined in `main.scad`, including dimensions, stair geometry, arch sizes, tower dimensions, and mesh quality.

## Scale and Measurements

The model uses a nominal **1:200 scale**.

Several dimensions were measured using Google Earth, while other geometric details were estimated from photographic references where precise measurements were not available.

The model is therefore an approximation of the real bridge, rather than an exact architectural survey.

## References and Acknowledgements

The modelling process made use of publicly available visual references:

- **Google Images** — reference photographs used to study the bridge's appearance, architectural details, and proportions.
- **Google Earth** — used to measure selected dimensions and trace/derive parts of the bridge's geometry from aerial and geographical imagery.

The reference images and geographical imagery belong to their respective owners and are acknowledged as sources of reference material. They are not included in this repository unless explicitly stated.

This project is an independently created 3D reconstruction for educational, personal, and modelling purposes. It is not an official model of Trepponti Bridge and is not affiliated with Google or the Municipality of Comacchio.
