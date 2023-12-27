#!/usr/bin/env python3

# config
mscore4 = "xvfb-run -a /home/hari/src/MuseScore/builds/Linux-Qt-usr-Make-Release/src/app/mscore"
mscore3 = "xvfb-run -a /usr/local/bin/mscore"

templates = "/daten/museview/musicbook-o-mat/templates/" # path to xsl-fo mako templates
songsdir = "/var/www/museview/assets/songs/satz" # path to musescore mscz files
svgdir = "file:///daten/museview/musescore-output" # path to SVG exports from mscz files
clipartdir = "file:///daten/museview/clipart"
maxindexsinglepage = 50
clipart = "file:///daten/museview/clipart/ornament.svg"
# config end

from mako.template import Template
import mako
import yaml
import json
import subprocess
import sys

if len(sys.argv) != 3:
    print("ERROR: please specify input YAML/JSON file and output XSL-FO file")
    exit(-1)

inputfile = sys.argv[1]
outputfilename = sys.argv[2]

evenpage = False
bookindex = {}
bookcontent = []

def yaml_or_json(file_name):
    with open(file_name) as f:
        try:
            json.load(f)
            return 'json'
        except Exception:
            return 'yaml'

with open(inputfile, "r") as stream:
    try:
        definition = {}
        if yaml_or_json(inputfile) == 'json':
            definition = json.load(stream)
        else:
            definition = yaml.safe_load(stream)

        for folder in definition['songs']:
            print(folder)
            bookindex[folder]=[]

            for song in definition['songs'][folder]:
                print("Processing: " + song)
                song_info = json.loads(subprocess.check_output(mscore4 + " --score-meta '" + songsdir + "/" + song + ".mscz' 2> /dev/null", shell=True))
                if song_info['metadata']['fileVersion'] <= 302: # if file has been written with pre-4 version, use latest 3.6 mscore to parse metadata
                    song_info = json.loads(subprocess.check_output(mscore3 + " --score-meta '" + songsdir + "/" + song + ".mscz' 2> /dev/null", shell=True))

                indexprettyname = song_info['metadata']['title'] + " (" + song_info['metadata']['composer'] + ")"
                if song_info['metadata']['composer'] == "":
                    indexprettyname = song_info['metadata']['title']
                indexprettyname = indexprettyname.replace("&", "&amp;")

                indexentry = {}
                indexentry['title'] = indexprettyname
                indexentry['song'] = song
                bookindex[folder].append(indexentry)

                if song_info['metadata']['pages']==2:
                    if not evenpage: # add filler clipart to start next song with even page
                        contententry = {}
                        contententry['path']=clipart
                        contententry['width']='270%'
                        contententry['topmargin']='70mm'
                        contententry['textalign']='center'
                        bookcontent.append(contententry)
                        evenpage = True

                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-1.svg'
                    contententry['width']='20%'
                    contententry['id']=song
                    contententry['breakeven']=True
                    bookcontent.append(contententry)

                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-2.svg'
                    contententry['width']='20%'
                    contententry['breakeven']=False
                    bookcontent.append(contententry)

                elif song_info['metadata']['pages']==3:
                    if not evenpage:
                        contententry = {}
                        contententry['path']=clipart
                        contententry['textalign']='center'
                        contententry['width']='270%'
                        contententry['topmargin']='70mm'
                        bookcontent.append(contententry)
                        evenpage = True

                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-1.svg'
                    contententry['id']=song
                    contententry['width']='20%'
                    contententry['breakeven']=True
                    bookcontent.append(contententry)

                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-2.svg'
                    contententry['width']='20%'
                    contententry['breakeven']=False
                    bookcontent.append(contententry)

                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-3.svg'
                    contententry['width']='20%'
                    contententry['breakeven']=False
                    bookcontent.append(contententry)

                    evenpage = False
                    
                else:
                    if evenpage:
                        evenpage = False
                    else:
                        evenpage = True
                    contententry = {}
                    contententry['path']=svgdir + '/' + song + '/' + song.split('/')[1] + '-1.svg'
                    contententry['width']='20%'
                    contententry['id']=song
                    contententry['breakeven']=False
                    bookcontent.append(contententry)

        outputfile = open(outputfilename, "w")

        try:
            template = Template(filename=templates + '/musicbook-a4.xsl', input_encoding='utf-8')
            if "title" in definition:
                outputfile.write(template.render(version=str(definition['version']),index=bookindex,content=bookcontent, title=definition['title']))
            else:
                outputfile.write(template.render(version=str(definition['version']),index=bookindex,content=bookcontent, cover=definition['cover']))

        # except mako.exceptions.SyntaxException:
        except:
            print(mako.exceptions.text_error_template().render())
            print("ERROR: Cannot write XSL-FO file!")

        #    outputfile.write('<fo:block><fo:external-graphic src="url('+ clipartdir + '/' + definition['cover'] + ')" content-width="77%"/></fo:block>')

        outputfile.close()
    except yaml.YAMLError as exc:
        print(exc)
