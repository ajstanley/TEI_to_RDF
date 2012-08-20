<?php

function tei_input_form(&$form_state, $pid) {

  $form = array();
  $form['link'] = array(
    '#type' => 'item',
    '#value' => l(t("Return to collection view"), "fedora/repository/$pid"),
  );

  $form['#attributes'] = array('enctype' => 'multipart/form-data');
  $form['file_upload'] = array(
    '#type' => 'file',
    '#title' => t('Upload TEI xml'),
    '#size' => 48,
    '#description' => t('Upload file'),
  );
  $form['title'] = array(
    '#type' => 'textfield',
    '#description' => t('Title of uploaded TEI'),
    '#title' => t("Title"),
    '#required' => TRUE,
  );

  $form['pid'] = array(
    '#type' => 'hidden',
    '#value' => $pid,
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#weight' => 10,
    '#value' => 'Create RDF'
  );

  return $form;
}

function tei_input_form_validate($form, &$form_state) {

  $fieldName = 'file_upload';
  if (isset($_FILES['files']) && is_uploaded_file($_FILES['files']['tmp_name'][$fieldName])) {
    $file = file_save_upload($fieldName);
    if (!$file) {
      form_set_error($fieldName, 'Error uploading file.');
      return;
    }
    $form_state['values']['file'] = $file->filepath;
  }
}

function tei_input_form_submit($form, &$form_state) {
  module_load_include('inc', 'fedora_repository', 'api/fedora_item');
  global $base_url;
  $collection_pid = $form_state['values']['pid'];
  $namespace = substr($collection_pid, 0, strpos($collection_pid, ":"));
  $title = $form_state['values']['title'];
  $pid = fedora_item::get_next_PID_in_namespace($namespace);
  $item = fedora_item::ingest_new_item($pid, 'A', $title, 'Owner');
  $path = drupal_get_path('module', 'interedition') . '/xslt';
  $file = $form_state['values']['file'];
  //get input tei
  $tei_string = file_get_contents($file);
  //create file dir and filepaths
  $flat_pid = str_replace(':', '_', $pid);
  $file_dir = file_directory_path() . "/$flat_pid";
  if (!is_dir($file_dir)) {
    mkdir($file_dir, 0766);
  }
  $inputTEIFile = "$file_dir/inputTEI.xml";
  $qualifiedTEIFile = "$file_dir/qualifiedTEI.xml";
  $RDFFile = "$file_dir/RDF.xml";
  //put tei in dir
  file_put_contents($inputTEIFile, $tei_string);

  // create xslt paths
  $addIDXSLT = "$base_url/$path/add_ids_to_elements.xsl";
  $rdfXSLT = "$base_url/$path/tei_with_relations_to_rdf.xsl";

  $qualifiedTEI = file_get_contents("http://localhost:8080/saxon/SaxonServlet?source=$base_url/$inputTEIFile&style=$addIDXSLT");
  file_put_contents($qualifiedTEIFile, $qualifiedTEI);

  $url = "http://localhost:8080/saxon/SaxonServlet?source=$base_url/$qualifiedTEIFile&style=$rdfXSLT";

  $RDF = file_get_contents("http://localhost:8080/saxon/SaxonServlet?source=$base_url/$qualifiedTEIFile&style=$rdfXSLT");
  file_put_contents($RDFFile, $RDF);

  //build object
  $thumbpath = drupal_get_path('module', 'interedition') . '/images/' . 'Crystal_Clear_mimetype_man.png';
  $item->add_datastream_from_file($inputTEIFile, 'TEI', 'TEI', 'text/xml');
  $item->add_datastream_from_file($qualifiedTEIFile, 'qualified', 'Qualified TEI', 'text/xml');
  $item->add_datastream_from_file($RDFFile, 'RDF', 'RDF', 'text/xml', "X");
  $item->add_datastream_from_file($thumbpath, 'TN', 'TN', 'image/png');
  $item->add_relationship('isMemberOfCollection', $collection_pid, RELS_EXT_URI);
  $item->add_relationship('hasModel', 'islandora:tei_rdf', FEDORA_MODEL_URI);


  drupal_goto("fedora/repository/$pid");
}

