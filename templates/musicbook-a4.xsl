<?xml version="1.0" encoding="utf-8"?>
<%doc>
XSL-FO template for A4 musicbooks. 

Input variables:
- title (optional)
- subtitle (optional)
- key (optional)
- index dict
- content dict

</%doc>
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
 <fo:layout-master-set>
    <fo:simple-page-master page-height="297mm" page-width="210mm" master-name="PageMasterTitle">
        <fo:region-body margin="0mm 0mm 0mm 0mm"/>
    </fo:simple-page-master>
    <fo:simple-page-master page-height="297mm" page-width="210mm" master-name="PageMasterIndex">
        <fo:region-body margin="20mm 20mm 20mm 20mm"/>
	<fo:region-after extent="10mm"/>
    </fo:simple-page-master>
    <fo:simple-page-master page-height="297mm" page-width="210mm" master-name="PageMaster">
        <fo:region-body margin="10mm 0mm 0mm 10mm"/>
	<fo:region-after extent="10mm"/>
    </fo:simple-page-master>
    <fo:simple-page-master page-height="297mm" page-width="210mm" master-name="even">
        <fo:region-body margin="10mm 0mm 0mm 10mm"/>
	<fo:region-after region-name="footer-even" extent="10mm"/>
    </fo:simple-page-master>
    <fo:simple-page-master page-height="297mm" page-width="210mm" master-name="odd">
        <fo:region-body margin="10mm 0mm 0mm 10mm"/>
	<fo:region-after region-name="footer-odd" extent="10mm"/>
    </fo:simple-page-master>

    <fo:page-sequence-master master-name="content">
	<fo:repeatable-page-master-alternatives>
	<fo:conditional-page-master-reference master-reference="odd" odd-or-even="odd"/>
	<fo:conditional-page-master-reference master-reference="even" odd-or-even="even"/>
    </fo:repeatable-page-master-alternatives>
</fo:page-sequence-master>

</fo:layout-master-set>

% if title:
<fo:page-sequence master-reference="PageMasterTitle">
<fo:flow flow-name="xsl-region-body">
<fo:block-container absolute-position="absolute" top="0cm" left="0cm" width="21cm" height="29.7cm" background-image="url(file:///daten/museview/clipart/corners.svg)">
	<fo:block></fo:block>
</fo:block-container>
	<!-- <fo:block background-image="url(file:///daten/museview/clipart/corners.svg)"> -->
        <fo:block margin-top="35mm" text-align="center" font-size="60pt" font-family="Edwin-Roman">Partituren</fo:block>
        <fo:block margin-top="10mm" text-align="center" font-size="30pt" font-family="Edwin-Roman">für Jagdhörner</fo:block>
	<fo:block margin-top="10mm" text-align="center" font-size="30pt" font-family="Edwin-Roman"><!--in E<fo:inline font-family="Edwin-Italic" font-style="italic">b</fo:inline>--></fo:block>
        <fo:block margin-top="20mm" text-align="center"><fo:external-graphic src="url(file:///daten/museview/clipart/horn-logo.svg)" content-width="67%"/></fo:block>
	<fo:block margin-top="20mm" text-align="center" font-size="45pt" font-family="Edwin-Roman">${title}</fo:block>
</fo:flow>
</fo:page-sequence>
% endif

% if cover:
<fo:page-sequence master-reference="PageMasterTitle">
<fo:flow flow-name="xsl-region-body">
	<fo:block><fo:external-graphic src="url(${clipart})" content-width="77%"/></fo:block>
</fo:flow>
</fo:page-sequence>
% endif

% if index:
<fo:page-sequence master-reference="PageMasterIndex">
	<fo:flow flow-name="xsl-region-body">

		% if version:
		<fo:block-container absolute-position="absolute" top="26.2cm" left="0cm" width="21cm" height="2cm">
			<fo:block text-align="left" font-family="Edwin-Roman">Version ${version}</fo:block>
		</fo:block-container>
		% endif
		% for section in index:
		<fo:block font-size="12pt" font-family="Edwin-Bold" font-weight="bold" margin-top="5mm" margin-bottom="2mm">${section}</fo:block>
			% for entry in index[section]:
			<fo:block text-align-last="justify" font-family="Edwin-Roman">
				<fo:basic-link internal-destination="${entry['song']}">
					${entry['title']}
					<fo:leader leader-pattern="dots" />
					<fo:page-number-citation ref-id="${entry['song']}"/>
				</fo:basic-link>
			</fo:block>
			% endfor
		% endfor
</fo:flow>
</fo:page-sequence>
% endif

 <fo:page-sequence master-reference="content">
    <fo:static-content flow-name="footer-even">
      <fo:block margin-left="7mm" text-align="left" font-family="Edwin-Roman"><fo:page-number/></fo:block><!-- Links -->
    </fo:static-content>
    <fo:static-content flow-name="footer-odd">
      <fo:block margin-right="7mm" text-align="right" font-family="Edwin-Roman"><fo:page-number/></fo:block>
    </fo:static-content>
    <fo:flow flow-name="xsl-region-body">
		% for entry in content:
	    <fo:block
	    ${'break-before="even-page"' if 'breakeven' in entry and entry['breakeven']==True else ''}
	    ${'margin-top="' + entry['topmargin'] +'"' if 'topmargin' in entry else ''}
	    ${'text-align="' + entry['textalign'] +'"' if 'textalign' in entry else ''}
	    >
			<fo:external-graphic src="url(${entry['path']})"
			${'id="' + entry['id'] +'"' if 'id' in entry else ''}
			${'content-width="' + entry['width'] +'"' if 'width' in entry else ''}
			/>
		</fo:block>
		% endfor
    </fo:flow>
  </fo:page-sequence>

</fo:root>
