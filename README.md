# ProteinMPNN

This repo includes the Kuhlman Lab fork of ProteinMPNN. It includes all the functionality of the original ProteinMPNN repo (linked [here](https://github.com/dauparas/ProteinMPNN)), with the following additions:
- Improved input parsing for custom design runs
- Multi-state design support
- Additional utilities to provide integration with [EvoPro](https://github.com/Kuhlman-Lab/evopro)

![ProteinMPNN](https://docs.google.com/drawings/d/e/2PACX-1vTtnMBDOq8TpHIctUfGN8Vl32x5ISNcPKlxjcQJF2q70PlaH2uFlj2Ac4s3khnZqG1YxppdMr0iTyk-/pub?w=889&h=358)
Read [ProteinMPNN paper](https://www.biorxiv.org/content/10.1101/2022.06.03.494563v1).

## 1. Anaconda Configuration:
```
cd ~/Downloads
curl -O https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
bash Anaconda3-2024.10-1-Linux-x86_64.sh
source ~/.bashrc
type “yes”
When asked whether to initialize Anaconda by running conda init, type “yes” to allow Anaconda to modify your shell configuration files.
logout and login
conda info

conda is configured
```
## 2. Mamba Configuration:
```
git clone https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh

Press Enter to page through the licence
Accept the licence
Wait for the installer to finish (at least 30 seconds)
When asked “Do you want to installer to initialize Miniconda by running conda init” then type “yes”
mamba info

mamba is configured
```

## 3. Proteinmpnn setup:
```
git clone git@github.com:Kuhlman-Lab/proteinmpnn.git
cd proteinmpnn
mamba env create -f setup/proteinmpnn.yml
conda activate mpnn
```

## Usage Guidelines:

### General Usage

The different input arguments available for each script can be viewed by adding `-h` to your python call (e.g., `python /home/asus/biotools/proteinmpnn/run/generate_json.py -h`).
```
python /home/asus/biotools/proteinmpnn/run/generate_json.py -h
usage: generate_json.py [-h] [--pdb_dir PDB_DIR] [--designable_res DESIGNABLE_RES] [--default_design_setting DEFAULT_DESIGN_SETTING] [--symmetric_res SYMMETRIC_RES]
                        [--cluster_center CLUSTER_CENTER] [--cluster_radius CLUSTER_RADIUS] [--out_path OUT_PATH] [--gap GAP] [--validation_tries VALIDATION_TRIES] [--bidirectional]
                        [--constraints CONSTRAINTS] [--multi_state]

Script that takes a PDB and designspecifications to create a json file for inputto ProteinMPNN

options:
  -h, --help            show this help message and exit
  --pdb_dir PDB_DIR     Path to the directory containing PDB files.
  --designable_res DESIGNABLE_RES
                        PDB chain and residue numbers to mutate, separated by commas and/or hyphens. E.g. A10,A12-A15.Multi-state requires filename prefix. E.g. PDB1:A10,A12-A15
  --default_design_setting DEFAULT_DESIGN_SETTING
                        Default setting amino acid types that residues are allowed to mutate to. Use 'all' to allow any amino acid to be design. Default is 'all'.
  --symmetric_res SYMMETRIC_RES
                        PDB chain and residue numbers to force symmetric design, separated by colons and commas. E.g. to force symmetry between residue A1 and A15 use 'A1:A15' and for
                        symmetry between residues 1-5 on chains A and B use 'A1-A5:B1-B15'. (Note that the number of residues on each side of the colon must be the same).Cannot be used in
                        multi-state mode.
  --cluster_center CLUSTER_CENTER
                        PDB chain and residue numbers which will serve as mutation centers. Every residue with a CA within --cluster_radius Angstroms will be mutatable
  --cluster_radius CLUSTER_RADIUS
                        Radius from cluster mutation centers in which to include residues for mutation. Default is 10.0 A.
  --out_path OUT_PATH   Path for output json file. Default is proteinmpnn_res_specs.json.
  --gap GAP             Gap (in Angstrom) between states in MSD intermediate structure. Only may be needed if your structures are very big. Default is 1000.0 A.
  --validation_tries VALIDATION_TRIES
                        If set to 0, will not check the MSD intermediate structure for clashes. Recommended when running MSD on a new system. Very slow!
  --bidirectional       Turn on bidirectional coding constraints. MSD only. Default is off.
  --constraints CONSTRAINTS
                        Semicolon-separated list of multi-state design constraints. commas separate individual residue sets within a constraint. E.g.
                        PDB1:A10-A15:1,PDB2:A10-A15:0.5;PDB1:A20-A25:1,PDB3:B20-B25:-1See examples/multi_state for details.
  --multi_state         Enable multi-state design (MSD) parsing.
```

ProteinMPNN accepts PDB files as input and produces FASTA files as output.

Unlike the original repo, our ProteinMPNN organizes the different input options (aka arguments) into `.flag` files:
- `json.flags` is used to specify design constraints, like fixed residues and symmetry
- `proteinmpnn.flags` is used to specify prediction flags, like which sampling temperature and model variant to use.

In general, there are two steps to running ProteinMPNN:
1. Run the `generate_json.py` script and pass it the `json.flags` file.
- This makes a new file called `proteinmpnn_res_specs.json` containing parsed design information.
2. Run the `run_protein_mpnn.py ` script and pass it `proteinmpnn.flags` and `proteinmpnn_res_specs.json` to obtain the actual ProteinMPNN prediction.

### Useful Flags

Used in `json.flags`:

`--default_design_setting`: this is an optional filter to allow/disallow certain residue types during design. By default, it is set to `all`, which allows all 20 amino acids. Possible settings include:
    `all-hydphob`: exclude hydrophobic residues (`CDEHKNPQRSTX`)
    `all-hydphil`: exclude hydrophilic residues (`ACFGILMPVWYX`)
    `all-CLD`: exclude specific amino acids (in this case, Cys, Leu, and Asp)
    `L+polar`: mix-and-match amino acids and categories (in this case, allow all polar amino acids and also Leu)

Used in `proteinmpnn.flags`:
`--model_name`: specifies which ProteinMPNN model checkpoint to use. Possible options include:
    `v_48_002`: vanilla (default) model with k=48 neighbors and 0.02A noise
    `s_48_010`: soluble protein model with k=48 neighbors and 0.1A noise

`--sampling_temp`: specifies the sampling temperature, which changes how diverse the generated sequences will be. Ranges from 0 to 1, inclusive. A temperature of 0 returns the "best" prediction every time (zero diversity), while a temperature of 1 will return completely random samples. Recommended range is 0.0 - 0.3 or so.

`--dump_probs`: if included, ProteinMPNN will save the predicted sequence probability table for each scaffold. This will be a numpy array of shape [L, 21], for a protein of length L. If multiple sequences are generated per scaffold, probabilities will be averaged before saving. A helper script for visualizing these tables is included at `run/helper_scripts/other_tools/view_probs.py`.

### Example Cases

Example input and expected output files, as well as jobscripts and flag files, for many different design tasks are included in `examples/`. For a summary and explanation of each example, see `examples/EXAMPLES.md`. Currently supported protocols include:

1. Monomer Design (with user-friendly parsing of designable residues)
2. Binder Design
2. Oligomer Design (with support for abitrary symmetries in homooligomers)
3. Multi-state Design (with support for multiple complex design constraints)

-----------------------------------------------------------------------------------------------------

## Unit Testing

TODO

## Code organization:
* `run/run_protein_mpnn.py` - the main script to initialialize and run the model.
* `run/generate_json.py` - function to automatically generate json of design constraints.
* `run/helper_scripts/` - helper functions to parse PDBs, assign which chains to design, which residues to fix, adding AA bias, tying residues etc.
* `examples/` - simple example inputs/outputs and runscripts for different tasks.
* `model_weights/` - trained proteinmpnn model weights.
    * `v_48_...` - vanilla proteinmpnn models trained at different noise levels.
    * `s_48_...` - solublempnn models trained at different noise levels.
    * `ca_48_...` - Ca-only models trained at different noise levels.


## License

ProteinMPNN is distributed under an MIT license, which can be found at `proteinmpnn/LICENSE`. See license file for more details.
