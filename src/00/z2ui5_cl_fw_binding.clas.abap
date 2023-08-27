CLASS z2ui5_cl_fw_binding DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE `ONE_WAY`,
        two_way  TYPE string VALUE `TWO_WAY`,
        one_time TYPE string VALUE `ONE_TIME`,
      END OF cs_bind_type.

    CONSTANTS cv_model_edit_name TYPE string VALUE `EDIT`.

    TYPES:
      BEGIN OF ty_s_attri,
        name            TYPE string,
        type_kind       TYPE string,
        type            TYPE string,
        bind_type       TYPE string,
        data_stringify  TYPE string,
        data_rtti       TYPE string,
        check_temp      TYPE abap_bool,
        check_tested    TYPE abap_bool,
        check_ready     TYPE abap_bool,
        check_dissolved TYPE abap_bool,
        name_front      TYPE string,
      END OF ty_s_attri.
    TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

    CLASS-METHODS factory
      IMPORTING
        app             TYPE REF TO object OPTIONAL
        attri           TYPE ty_t_attri OPTIONAL
        type            TYPE string OPTIONAL
        data            TYPE data OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_binding.

    METHODS main
      RETURNING
        VALUE(result) TYPE string.

    METHODS main2
      RETURNING
        VALUE(result) TYPE string.

    DATA mo_app   TYPE REF TO object.
    DATA mt_attri TYPE ty_t_attri.
    DATA mv_type  TYPE string.
    DATA mr_data TYPE REF TO data.

    CLASS-METHODS update_attri
      IMPORTING
        t_attri       TYPE ty_t_attri
        app           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE ty_t_attri.

  PROTECTED SECTION.

    METHODS bind_local
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_t_attri_by_dref
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS get_t_attri_by_struc
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS get_t_attri_by_oref
      IMPORTING
        val           TYPE clike OPTIONAL
        check_temp    type abap_bool DEFAULT abap_false
        PREFERRED PARAMETER val
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS bind
      IMPORTING
        bind          TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS dissolve_init.

    METHODS dissolve_struc.

    METHODS dissolve_dref.

    METHODS search_binding
      RETURNING
        VALUE(result) TYPE string.

    METHODS dissolve_oref.

    METHODS set_attri_ready
      IMPORTING
        t_attri       TYPE REF TO ty_t_attri
      RETURNING
        VALUE(result) TYPE REF TO ty_s_attri.

    METHODS name_front_create
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_fw_binding IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->mo_app = app.
    r_result->mt_attri = attri.
    r_result->mv_type = type.

    IF z2ui5_cl_fw_utility=>rtti_check_type_kind_dref( data ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_fw_error
        EXPORTING
          val = `BINDING_WITH_REFERENCES_NOT_ALLOWED`.
    ENDIF.
    GET REFERENCE OF data INTO r_result->mr_data.

  ENDMETHOD.


  METHOD dissolve_init.
      DATA temp1 LIKE REF TO mt_attri.
      DATA temp2 LIKE LINE OF mt_attri.
      DATA lr_attri LIKE REF TO temp2.

    IF mt_attri IS INITIAL.

      mt_attri  = get_t_attri_by_oref( ).
      
      GET REFERENCE OF mt_attri INTO temp1.
set_attri_ready( temp1 ).

    ELSE.
      
      
      LOOP AT mt_attri REFERENCE INTO lr_attri.
        lr_attri->check_tested = abap_false.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_t_attri_by_oref.

    DATA temp3 TYPE string.
    DATA lv_name LIKE temp3.
    FIELD-SYMBOLS <obj> TYPE any.
    DATA lt_attri2 TYPE abap_attrdescr_tab.
    DATA ls_attri2 LIKE LINE OF lt_attri2.
      DATA temp4 TYPE ty_s_attri.
      DATA ls_attri LIKE temp4.
    IF val IS NOT INITIAL.
      temp3 = `MO_APP` && `->` && val.
    ELSE.
      temp3 = `MO_APP`.
    ENDIF.
    
    lv_name = temp3.
    
    ASSIGN (lv_name) TO <obj>.
    IF sy-subrc <> 0 OR <obj> IS NOT BOUND.
      RETURN.
    ENDIF.

    
    lt_attri2 = z2ui5_cl_fw_utility=>rtti_get_t_attri_by_object( <obj> ).
*    DELETE lt_attri2 WHERE visibility <> cl_abap_classdescr=>public OR is_interface = abap_true.

    
    LOOP AT lt_attri2 INTO ls_attri2
        where visibility = cl_abap_classdescr=>public
           and is_interface = abap_false.
      
      CLEAR temp4.
      MOVE-CORRESPONDING ls_attri2 TO temp4.
      
      ls_attri = temp4.
      ls_attri-check_temp = check_temp.
      IF val IS NOT INITIAL.
        ls_attri-name = val && `->` && ls_attri-name.
      ENDIF.
      INSERT ls_attri INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD main2.

    dissolve_init( ).

    "step 0 / MO_APP->MV_VAL
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 2 / MO_APP->MR_DATA->*
    dissolve_dref( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_oref( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_dref( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE z2ui5_cx_fw_error
      EXPORTING
        val = `Binding Error - No attribute found`.

  ENDMETHOD.

  METHOD main.

    IF mv_type = cs_bind_type-one_time.
      result = bind_local(  ).
      RETURN.
    ENDIF.

    "step 0 / MO_APP->MV_VAL
    dissolve_init( ).

    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    "step 2 / MO_APP->MR_DATA->*
    dissolve_dref( ).
    "step 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    "step 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_oref( ).
    "step 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    "step 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_dref( ).
    "step 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
    dissolve_struc( ).

    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE z2ui5_cx_fw_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class`.

  ENDMETHOD.


  METHOD bind_local.

    FIELD-SYMBOLS <any> TYPE any.
    DATA lv_id TYPE string.
    DATA temp5 TYPE z2ui5_cl_fw_binding=>ty_s_attri.
    ASSIGN mr_data->* TO <any>.
    
    lv_id = z2ui5_cl_fw_utility=>func_get_uuid_22( ).
    
    CLEAR temp5.
    temp5-name = lv_id.
    temp5-data_stringify = z2ui5_cl_fw_utility=>trans_json_any_2( mr_data ).
    temp5-bind_type = cs_bind_type-one_time.
    INSERT temp5
           INTO TABLE mt_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.

  METHOD bind.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA lv_name TYPE string.
    DATA lr_ref TYPE REF TO data.
    DATA temp6 TYPE string.
      DATA temp7 TYPE string.
    lv_name = `MO_APP->` && bind->name.
    ASSIGN (lv_name) TO <attri>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_fw_error.
    ENDIF.

    
    GET REFERENCE OF <attri> INTO lr_ref.

    IF mr_data <> lr_ref.
      RETURN.
    ENDIF.

    IF bind->bind_type <> mv_type AND bind->bind_type IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_fw_error
        EXPORTING
          val = `<p>Binding Error - Two different binding types for same attribute used (` && bind->name && `).`.
    ENDIF.

    bind->bind_type  = mv_type.
    bind->name_front = name_front_create( val = bind->name ).

    
    IF mv_type = cs_bind_type-two_way.
      temp6 = `/` && cv_model_edit_name && `/`.
    ELSE.
      temp6 = `/`.
    ENDIF.
    result = temp6 && bind->name_front.
    IF strlen( result ) > 30.
      bind->name_front = z2ui5_cl_fw_utility=>func_get_uuid_22( ).
      
      IF mv_type = cs_bind_type-two_way.
        temp7 = `/` && cv_model_edit_name && `/`.
      ELSE.
        temp7 = `/`.
      ENDIF.
      result = temp7 && bind->name_front.
    ENDIF.

  ENDMETHOD.

  METHOD get_t_attri_by_struc.

    DATA lv_name TYPE string.
    FIELD-SYMBOLS <attribute> TYPE any.
    DATA temp1 TYPE xsdboolean.
    DATA lt_comp TYPE abap_component_tab.
    DATA lv_attri TYPE string.
    DATA temp8 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp8.
      DATA lv_element TYPE string.
        DATA lt_attri TYPE z2ui5_cl_fw_binding=>ty_t_attri.
        DATA temp9 TYPE ty_s_attri.
        DATA ls_attri LIKE temp9.
    lv_name = `MO_APP->` && val.
    
    ASSIGN (lv_name) TO <attribute>.
    
    temp1 = boolc( sy-subrc <> 0 ).
    z2ui5_cl_fw_utility=>x_check_raise( temp1 ).

    
    lt_comp = z2ui5_cl_fw_utility=>rtti_get_t_comp_by_struc( <attribute> ).
    
    lv_attri = z2ui5_cl_fw_utility=>c_replace_assign_struc( val ).
    
    
    LOOP AT lt_comp REFERENCE INTO lr_comp.

      
      lv_element = lv_attri && lr_comp->name.

      IF lr_comp->as_include = abap_true
      OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct2
      OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct1.

        
        lt_attri = get_t_attri_by_struc( lv_element ).
        INSERT LINES OF lt_attri INTO TABLE result.

      ELSE.
        
        CLEAR temp9.
        temp9-name = lv_element.
        temp9-type_kind = lr_comp->type->type_kind.
        
        ls_attri = temp9.
        INSERT ls_attri INTO TABLE result.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_struc.

    DATA temp10 TYPE ty_t_attri.
    DATA lt_dissolve LIKE temp10.
    DATA temp11 LIKE LINE OF mt_attri.
    DATA lr_attri LIKE REF TO temp11.
      DATA lt_attri TYPE z2ui5_cl_fw_binding=>ty_t_attri.
    DATA temp12 LIKE REF TO lt_dissolve.
    CLEAR temp10.
    
    lt_dissolve = temp10.

    
    
    LOOP AT mt_attri REFERENCE INTO lr_attri
        WHERE type_kind = cl_abap_classdescr=>typekind_struct1
        OR    type_kind = cl_abap_classdescr=>typekind_struct2
        AND   check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.
      
      lt_attri = get_t_attri_by_struc( lr_attri->name ).
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    
    GET REFERENCE OF lt_dissolve INTO temp12.
set_attri_ready( temp12 ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD dissolve_dref.

    DATA temp13 TYPE ty_t_attri.
    DATA lt_dissolve LIKE temp13.
    DATA temp14 LIKE LINE OF mt_attri.
    DATA lr_bind LIKE REF TO temp14.
      DATA lt_attri TYPE z2ui5_cl_fw_binding=>ty_t_attri.
    DATA temp15 LIKE REF TO lt_dissolve.
    CLEAR temp13.
    
    lt_dissolve = temp13.

    
    
    LOOP AT mt_attri REFERENCE INTO lr_bind
        WHERE type_kind = cl_abap_classdescr=>typekind_dref
        AND   check_dissolved = abap_false.

      
      lt_attri = get_t_attri_by_dref( lr_bind->name ).
      lr_bind->check_dissolved = abap_true.
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    
    GET REFERENCE OF lt_dissolve INTO temp15.
set_attri_ready( temp15 ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD search_binding.

    DATA temp16 LIKE LINE OF mt_attri.
    DATA lr_bind LIKE REF TO temp16.
    LOOP AT mt_attri REFERENCE INTO lr_bind
        WHERE ( bind_type = `` OR bind_type = mv_type )
        AND   check_ready = abap_true
        AND   check_tested = abap_false.

      lr_bind->check_tested = abap_true.
      result = bind( lr_bind ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_oref.

    DATA temp17 TYPE ty_t_attri.
    DATA lt_dissolve LIKE temp17.
    DATA temp18 LIKE LINE OF mt_attri.
    DATA lr_bind LIKE REF TO temp18.
      DATA lt_attri TYPE z2ui5_cl_fw_binding=>ty_t_attri.
    DATA temp19 LIKE REF TO lt_dissolve.
    CLEAR temp17.
    
    lt_dissolve = temp17.

    
    
    LOOP AT mt_attri REFERENCE INTO lr_bind
      WHERE type_kind = cl_abap_classdescr=>typekind_oref
      AND   check_dissolved = abap_false.


      
      lt_attri = get_t_attri_by_oref( val = lr_bind->name check_temp = abap_true ).
      IF lt_attri IS INITIAL.
        CONTINUE.
      ENDIF.
      lr_bind->check_dissolved = abap_true.
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    
    GET REFERENCE OF lt_dissolve INTO temp19.
set_attri_ready( temp19 ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD set_attri_ready.

    LOOP AT t_attri->*  REFERENCE INTO  result
      WHERE check_ready = abap_false.

      CASE result->type_kind.
        WHEN cl_abap_classdescr=>typekind_iref
          OR cl_abap_classdescr=>typekind_intf.
          DELETE t_attri->*.

        WHEN cl_abap_classdescr=>typekind_oref
          OR cl_abap_classdescr=>typekind_dref
          OR cl_abap_classdescr=>typekind_struct2
          OR cl_abap_classdescr=>typekind_struct1.

        WHEN OTHERS.
          result->check_ready = abap_true.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD update_attri.

    DATA lo_bind TYPE REF TO z2ui5_cl_fw_binding.
    CREATE OBJECT lo_bind TYPE z2ui5_cl_fw_binding.
    lo_bind->mo_app = app.
    lo_bind->mt_attri = t_attri.

    lo_bind->dissolve_init( ).

    lo_bind->dissolve_oref( ).
    lo_bind->dissolve_oref( ).
    lo_bind->dissolve_dref( ).

    result = lo_bind->mt_attri.

  ENDMETHOD.


  METHOD get_t_attri_by_dref.

    DATA lv_name TYPE string.
    FIELD-SYMBOLS <data> TYPE any.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp20 TYPE ty_s_attri.
    DATA ls_new_bind LIKE temp20.
    lv_name = `MO_APP->` && val && `->*`.
    
    ASSIGN (lv_name) TO <data>.
    IF <data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    
    lo_descr = cl_abap_datadescr=>describe_by_data( <data> ).

    
    CLEAR temp20.
    temp20-name = val && `->*`.
    temp20-type_kind = lo_descr->type_kind.
    temp20-type = lo_descr->get_relative_name( ).
    temp20-check_temp = abap_true.
    temp20-check_ready = abap_true.
    
    ls_new_bind = temp20.

    INSERT ls_new_bind INTO TABLE result.

  ENDMETHOD.



  METHOD name_front_create.

    result = replace( val = val    sub = `*` with = `_` occ = 0 ).
    result = replace( val = result sub = `>` with = `_` occ = 0 ).
    result = replace( val = result sub = `-` with = `_` occ = 0 ).

  ENDMETHOD.

ENDCLASS.
