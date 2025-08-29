#!/bin/bash

# Vérifier si un argument est fourni
if [ $# -ne 2 ] ; then
    echo "Usage: $0 <fichier .bit>  <fichier .bin>"
    exit 1
fi

# Vérifier si le fichier .bit existe
if [ ! -f "$1" ]; then
    echo "Erreur: Le fichier $1 n'existe pas"
    exit 1
fi

# Créer le script TCL temporaire avec échappement correct
cat > temp.tcl << EOF
write_cfgmem -format bin -size 32 -loadbit "up 0x0 $1" -file $2 -disablebitswap
exit
EOF

# Exécuter Vivado
echo "Conversion de $1 vers $2..."
/tools/Xilinx/Vivado/2022.2/bin/vivado -mode batch -source temp.tcl

# Vérifier si la conversion a réussi
if [ $? -eq 0 ] && [ -f "$2" ]; then
    echo "Conversion réussie: $1.bin créé"
else
    echo "Erreur lors de la conversion"
    exit 1
fi

# Nettoyer le fichier temporaire
rm -f temp.tcl

echo "Terminé."
