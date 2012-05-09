README
------

This repository holds files for converting TEI/XML encoded text documents into RDF/XML through XSL transformations. The RDF triples generated from the transform are subject_predicate_object relations within the TEI document. 

RDF output has been checked against the W3C's RDF Validation Service: http://www.w3.org/RDF/Validator/  

To run: 
1. Check that your document conforms to the TEI-Bare customisation of TEI, as given at http://www.tei-c.org/Guidelines/Customization/ (for convenience, the RNG schema for TEI-Bare as of May 2012 is available in the /xslt/examples folder of this repository).
2. Apply the add-ids-to-elements XSLT to your TEI document.
3. Apply the tei-bare-to-RDF XSLT to the document output from the previous XSL transformation.
4. To make URIs deferenceable in the resulting RDF, perform a global search-and-replace on the resulting RDF output, to replace http://www.example.com/add-default-namespace-here# with the default namespace for where your TEI document will be published.
(e.g. replace http://www.example.com/add-default-namespace-here# with http://www.ancientwisdoms.ac.uk/mss/docName#)

MORE DETAILS
------------

xslt/tei_bare_to_rdf.xsl:
________________________

For extracting RDF triples from TEI-Bare compliant documents.

This XSLT file is for transforming files that are marked up with TEI tags conforming to the TEI_Bare schema, the minimum tagset for a TEI encoding (see http://www.tei_c.org/Guidelines/Customization/ for details of different TEI customisations and corresponding schemas).

This XSLT extracts RDF triples from TEI_bare conformant documents. The vocabulary for the predicates used in these RDF triples is largely drawn from the Dublin Core model for expressing metadata information about a document (see http://dublincore.org/ ).

Generally best results will be achieved if this XSLT is applied after first applying the add-ids-to-elements XSLT (see below).


xslt/add-ids-to-elements:
------------------------
For allocating xml:ids to elements which do not already have an xml:id attribute.

This XSLT file generates copies of TEI-compliant documents which are identical except that any element in the original document that does not have an xml:id attribute is allocated a distinct xml:id attribute in the XML file output through this transform. 

Run this XSLT before running a TEI to RDF transform, unless you have already allocated xml:ids to every element in your TEI document. This ensures that RDF triples can point to specific parts of your document. The output of this XSLT should replace your original TEI document when published, so that the generated xml:ids exist in your published TEI.


xslt/examples directory:
------------------------

- tei_bare_example.xml
- tei_bare.rng
- tei_bare_example_with_ids.xml
- tei_bare_example_with_ids.rdf

Example TEI-bare file and corresponding RNG schema, for testing. We have tested using Oxygen with the Saxon B transformer. 

The tei_bare_example_with_ids.xml shows the TEI document after applying the add-ids-to-elements XSLT and before applying the tei-bare-to-rdf XSLT. 

The tei_bare_example_with_ids.rdf file gives the final RDF output generated during testing.

xslt/existing-tei-c-files directory:
-----------------------------------
For reference only. Existing work on TEI-to-RDF transforms, carried out by members of the TEI-C Special Interest Group on TEI and ontologies (http://www.tei-c.org/SIG/Ontologies). This work (http://www.tei-c.org/release/xml/tei/stylesheet/rdf/) concentrates on using the CIDOC-CRM reference model (http://www.cidoc-crm.org/) as a basis for the RDF vocabulary, as opposed to the Dublin Core metadata model (http://dublincore.org/) which we employ. 