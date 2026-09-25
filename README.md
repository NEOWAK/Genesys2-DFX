# Genesys2-DFX

![FPGA](https://img.shields.io/badge/FPGA-Xilinx-blue)
![Languages](https://img.shields.io/badge/Langages-VHDL%20%7C%20C-blue)

## Description

Ce dépôt contient les fichiers sources, scripts et documents relatifs au projet de reconfiguration dynamique (Dynamic Function eXchange, DFX) sur la carte FPGA Digilent Genesys2. Le projet combine développement matériel sous Vivado, programmation du MicroBlaze via Vitis et gestion des bitstreams partiels pour une reconfiguration sécurisée et dynamique.

## Contenu

- Vidéo démontrant la réalisation complète du projet final.  
- Script Tcl automatisant la génération du projet Vivado.  
- Codes et scripts annexes (HDL, C, fichiers de contraintes).  
- Documentation détaillée des choix techniques et du déroulement.

## Installation

1. Cloner le dépôt :  
```bash
 git clone https://github.com/NEOWAK/Genesys2-DFX.git
 ```

2. Installer Vivado Design Suite et Vitis (versions 2022.2).  
3. Exécuter le script Tcl situé à la racine du projet pour générer la configuration du projet Vivado :
```bash
 vivado -mode batch -source final2.tcl -nojournal -nolog -notrace
 ```

4. Compiler et programmer la cible avec Vitis.

## Usage

- Suivre la [![vidéo didactique](https://videos.insa-rennes.fr/media/videos/182befdf628bcb4e3c80701fc4e9c01268c2cd16389dc84be8f951e39a57de18/thumbnail.jpg)](https://videos.insa-rennes.fr/media/videos/182befdf628bcb4e3c80701fc4e9c01268c2cd16389dc84be8f951e39a57de18/video.mp4)  pour le déroulement complet du projet.
- Modifier les fichiers source selon vos besoins.  
- Utiliser les scripts fournis pour automatiser la génération des bitstreams.

## Contribution

Les contributions sont les bienvenues. Veuillez ouvrir une issue pour proposer des améliorations ou signaler des bugs.

## Licence

Projet à usage pédagogique. Toute utilisation commerciale est soumise à autorisation.

---

Pour toute question, contactez-moi via GitHub.
