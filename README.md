# musicbook-o-mat
Generates an XSL-FO musicbook from musescore input files.

# Usage

## Prerequisites

SVG exports for the referenced Musescore files need to be precreated. Path can be adjusted in the script. Path to mscore files needs to be specified in the script.

## Input file

The input file can be either JSON or YAML with the following structure:

~~~
title: Musicbook
version: 3
songs:
  Section A:
  - dir1/Kleine_Nachtmusik
  - dir2/Menuett
  Another Section:
  - dir1/Fanfare
~~~

The directory prefix is required for each item and refers to the score directory setting in the python script. Filenames are specified without '.mscz' extension.

## Output file

The output XSL-FO file is based on the template and will contain a generated (and linked) index.

## Generating a PDF

This can be done e.g. via Apache FOP. The XSL template makes use of the Musescore "Edwin" font. A config file for FOP to find it could look like this (specified via `-c`):

~~~
<fop version="1.0">
	<renderers>
		<renderer mime="application/pdf">
			<fonts>
				<directory recursive="true">/usr/share/fonts/opentype/musescore</directory>
				       <auto-detect/>
             </fonts>
		</renderer>
	</renderers>
</fop>
~~~
