"""Code for configuring the appearance of the HPatches results figure.

For each descriptor, a name and a colour that will be used in the
figure can be configured.

You can add new descriptors as shown example below:
'desc':
Descriptor(name='Desc++', color='darksalmon'),

This will add a new descriptor, using the results from the `desc`
folder, with name appearing in the figure as `Desc++`, and
darksalmon colour.

The colour string, has to be a valid names colour, from the following
list:
https://matplotlib.org/examples/color/named_colors.html

Note that `new_descriptor` should match the name of the folder
containing the HPatches results.
"""
import collections

Descriptor = collections.namedtuple('Descriptor', 'name color')
desc_info = {
    'sift': Descriptor(name='SIFT', color='seagreen'),
    'rootsift': Descriptor(name='RSIFT', color='olive'),
    'orb': Descriptor(name='ORB', color='skyblue'),
    'brief': Descriptor(name='BRIEF', color='darkcyan'),
    'binboost': Descriptor(name='BBoost', color='steelblue'),
    'tfeat-liberty': Descriptor(name='TFeat-LIB', color='teal'),
    'geodesc': Descriptor(name='GeoDesc', color='tomato'),
    'hardnet-liberty': Descriptor(name='HNet-LIB', color='chocolate'),
    'deepdesc-ubc': Descriptor(name='DDesc-LIB', color='black'),
    'NCC': Descriptor(name='LearnedSIFT', color='blue'),
    # Add you own descriptors as below:
    # 'desc':
    # Descriptor(name='Desc++', color='darksalmon'),
}

# Symbols for the figure
figure_attributes = {
    'intra_marker': ".",
    'inter_marker': "d",
    'viewp_marker': "*",
    'illum_marker': r"$\diamond$",
    'easy_colour': 'green',
    'hard_colour': "purple",
    'tough_colour': "red",
}
