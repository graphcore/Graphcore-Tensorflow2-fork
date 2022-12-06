import sys
import pathlib
_ogb_competition_directory = pathlib.Path(__file__).resolve().parent / "pcqm4mv2_submission"
sys.path.insert(0, str(_ogb_competition_directory))

# Make it look like this file is the original notebook_utils
from ogb_utils import *