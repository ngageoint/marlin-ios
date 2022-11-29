#!/bin/bash

#  initialData.sh
#  Marlin
#
#  Created by Daniel Barela on 9/8/22.
#

SAVE_DIR=../Marlin/Resources/SeedData

echo "Downloading initial ASAM data file"
curl -o $SAVE_DIR/asam.json "https://msi.gs.mil/api/publications/asam?sort=date&output=json"

echo "Downloading initial MODU data file"
curl -o $SAVE_DIR/modu.json "https://msi.gs.mil/api/publications/modu?output=json"

echo "Downloading initial Light data files"
curl -o $SAVE_DIR/lights.json "https://msi.gs.mil/api/publications/ngalol/lights-buoys?includeRemovals=false&output=json"

echo "Downloading initial Port data file"
curl -o $SAVE_DIR/port.json "https://msi.gs.mil/api/publications/world-port-index?output=json"

echo "Downloading initial Radio Beacon data file"
curl -o $SAVE_DIR/radioBeacon.json "https://msi.gs.mil/api/publications/ngalol/radiobeacons?output=json&includeRemovals=false"

echo "Downloading initial Differential GPS Station data file"
curl -o $SAVE_DIR/dgps.json "https://msi.gs.mil/api/publications/ngalol/dgpsstations?output=json&includeRemovals=false"

echo "Downloading initial DFRS data file"
curl -o $SAVE_DIR/dfrs.json "https://msi.gs.mil/api/publications/radio-navaids/dfrs?output=json"

echo "Downloading initial DFRS Areas data file"
curl -o $SAVE_DIR/dfrsAreas.json "https://msi.gs.mil/api/publications/radio-navaids/dfrs/areas"

echo "Downloading initial NTM data"
curl -o $SAVE_DIR/ntm.json "https://msi.gs.mil/api/publications/ntm/pubs?output=json"

echo "Downloading initial EPUB data"
curl -o $SAVE_DIR/epub.json "https://msi.gs.mil/api/publications/stored-pubs"
