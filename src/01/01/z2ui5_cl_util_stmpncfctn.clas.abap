CLASS z2ui5_cl_util_stmpncfctn DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_data_element_texts,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_data_element_texts .

    CLASS-METHODS method_get_source
      IMPORTING
        !iv_classname  TYPE clike
        !iv_methodname TYPE clike
      RETURNING
        VALUE(result)  TYPE string_table.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        !i_data_element_name TYPE string
      RETURNING
        VALUE(result)        TYPE ty_data_element_texts.

    CLASS-METHODS conv_decode_x_base64
      IMPORTING
        !val          TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_encode_x_base64
      IMPORTING
        !val          TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_string_by_xstring
      IMPORTING
        !val          TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_xstring_by_string
      IMPORTING
        !val          TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_stmpncfctn IMPLEMENTATION.


  METHOD conv_decode_x_base64.
        DATA classname TYPE c LENGTH 15.

    TRY.

        CALL METHOD ('CL_WEB_HTTP_UTILITY')=>('DECODE_X_BASE64')
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

      CATCH cx_sy_dyn_call_illegal_class.

        
        classname = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('DECODE_X_BASE64')
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

    ENDTRY.

  ENDMETHOD.


  METHOD conv_encode_x_base64.
        DATA classname TYPE c LENGTH 15.

    TRY.

        CALL METHOD ('CL_WEB_HTTP_UTILITY')=>('ENCODE_X_BASE64')
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_sy_dyn_call_illegal_class.

        
        classname = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('ENCODE_X_BASE64')
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.


  METHOD conv_get_string_by_xstring.

    DATA conv TYPE REF TO object.
        DATA conv_in_class TYPE c LENGTH 18.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_IN~CONVERT')
          EXPORTING
            source = val
          RECEIVING
            result = result.
      CATCH cx_sy_dyn_call_illegal_class.

        
        conv_in_class = 'CL_ABAP_CONV_IN_CE'.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            input = val
          IMPORTING
            data  = result.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_get_xstring_by_string.

    DATA conv TYPE REF TO object.
        DATA conv_out_class TYPE c LENGTH 19.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_OUT~CONVERT')
          EXPORTING
            source = val
          RECEIVING
            result = result.
      CATCH cx_sy_dyn_call_illegal_class.

        
        conv_out_class = 'CL_ABAP_CONV_OUT_CE'.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            data   = val
          IMPORTING
            buffer = result.
    ENDTRY.

  ENDMETHOD.


  METHOD method_get_source.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source TYPE string_table.
    DATA lt_string TYPE string_table.
        DATA lv_class TYPE string.
        DATA lv_method TYPE string.
        DATA lv_name TYPE c LENGTH 13.
        DATA lv_check_method LIKE abap_false.
        DATA lv_source LIKE LINE OF lt_source.
          DATA lv_source_upper TYPE string.

    TRY.

        
        lv_class  = to_upper( iv_classname ).
        
        lv_method = to_upper( iv_methodname ).

        CALL METHOD ('XCO_CP_ABAP')=>('CLASS')
          EXPORTING
            iv_name  = lv_class
          RECEIVING
            ro_class = object.

        ASSIGN ('OBJECT->IF_XCO_AO_CLASS~IMPLEMENTATION') TO <any>.
        object = <any>.

        CALL METHOD object->('IF_XCO_CLAS_IMPLEMENTATION~METHOD')
          EXPORTING
            iv_name   = lv_method
          RECEIVING
            ro_method = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD~CONTENT')
          RECEIVING
            ro_content = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE')
          RECEIVING
            rt_source = result.

      CATCH cx_sy_dyn_call_error.

        
        lv_name = 'CL_OO_FACTORY'.
        CALL METHOD (lv_name)=>('CREATE_INSTANCE')
          RECEIVING
            result = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE')
          EXPORTING
            clif_name = lv_class
          RECEIVING
            result    = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE~GET_SOURCE')
          IMPORTING
            source = lt_source.

        
        lv_check_method = abap_false.
        
        LOOP AT lt_source INTO lv_source.
          
          lv_source_upper = to_upper( lv_source ).

          IF lv_source_upper CS `ENDMETHOD`.
            lv_check_method = abap_false.
          ENDIF.

          IF lv_source_upper CS `METHOD ` && lv_method.
            lv_check_method = abap_true.
            CONTINUE.
          ENDIF.

          IF lv_check_method = abap_true.
            INSERT lv_source INTO TABLE lt_string.
          ENDIF.

        ENDLOOP.

    ENDTRY.

    result = lt_string.

  ENDMETHOD.


  METHOD rtti_get_classes_impl_intf.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.

    TYPES:
      BEGIN OF ty_s_impl,
        clsname    TYPE c LENGTH 30,
        refclsname TYPE c LENGTH 30,
      END OF ty_s_impl.
    DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_s_key,
             intkey TYPE c LENGTH 30,
           END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
        DATA lv_fm TYPE string.
        DATA temp1 LIKE LINE OF lt_impl.
        DATA lr_impl LIKE REF TO temp1.
          DATA temp2 TYPE string.

    TRY.

        CALL METHOD ('XCO_CP_ABAP')=>interface
          EXPORTING
            iv_name      = val
          RECEIVING
            ro_interface = obj.


        ASSIGN obj->('IF_XCO_AO_INTERFACE~IMPLEMENTATIONS') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        ASSIGN obj->('IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET').

        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES')
          RECEIVING
            rt_names = lt_implementation_names.

        result = lt_implementation_names.

      CATCH cx_sy_dyn_call_illegal_class.

        ls_key-intkey = val.

        
        lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
        CALL FUNCTION lv_fm
          EXPORTING
            intkey       = ls_key
          IMPORTING
            impkeys      = lt_impl
          EXCEPTIONS
            not_existing = 1
            OTHERS       = 2.

        
        
        LOOP AT lt_impl REFERENCE INTO lr_impl.
          
          temp2 = lr_impl->clsname.
          INSERT temp2 INTO TABLE result.
        ENDLOOP.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_get_data_element_texts.

    DATA:
      data_element_name TYPE c LENGTH 30,
      ddic_ref          TYPE REF TO data,
      data_element      TYPE REF TO object,
      content           TYPE REF TO object,
      BEGIN OF ddic,
        reptext   TYPE string,
        scrtext_s TYPE string,
        scrtext_m TYPE string,
        scrtext_l TYPE string,
      END OF ddic,
      exists TYPE abap_bool.
        DATA temp3 TYPE REF TO cl_abap_structdescr.
        DATA struct_desrc LIKE temp3.
        FIELD-SYMBOLS <ddic> TYPE any.
        DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp4 TYPE REF TO cl_abap_datadescr.
        DATA data_descr LIKE temp4.

    data_element_name = i_data_element_name.

    TRY.
        cl_abap_typedescr=>describe_by_name( 'T100' ).

        
        temp3 ?= cl_abap_structdescr=>describe_by_name( 'DFIES' ).
        
        struct_desrc = temp3.

        CREATE DATA ddic_ref TYPE HANDLE struct_desrc.
        
        ASSIGN ddic_ref->* TO <ddic>.
        ASSERT sy-subrc = 0.

        
        cl_abap_elemdescr=>describe_by_name(
           EXPORTING
             p_name         = data_element_name
           RECEIVING
             p_descr_ref    = lo_typedescr
           EXCEPTIONS
             OTHERS         = 1 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        
        temp4 ?= lo_typedescr.
        
        data_descr = temp4.

        CALL METHOD data_descr->('GET_DDIC_FIELD')
          RECEIVING
            p_flddescr   = <ddic>
          EXCEPTIONS
            not_found    = 1
            no_ddic_type = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        MOVE-CORRESPONDING <ddic> TO ddic.
        result-header = ddic-reptext.
        result-short  = ddic-scrtext_s.
        result-medium = ddic-scrtext_m.
        result-long   = ddic-scrtext_l.

      CATCH cx_root.
        TRY.
            CALL METHOD ('XCO_CP_ABAP_DICTIONARY')=>('DATA_ELEMENT')
              EXPORTING
                iv_name         = data_element_name
              RECEIVING
                ro_data_element = data_element.

            CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~EXISTS')
              RECEIVING
                rv_exists = exists.

            IF exists = abap_false.
              RETURN.
            ENDIF.

            CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~CONTENT')
              RECEIVING
                ro_content = content.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL')
              RECEIVING
                rs_heading_field_label = result-header.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL')
              RECEIVING
                rs_short_field_label = result-short.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL')
              RECEIVING
                rs_medium_field_label = result-medium.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL')
              RECEIVING
                rs_long_field_label = result-long.

          CATCH cx_root.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD uuid_get_c22.

    DATA uuid TYPE c LENGTH 22.
            DATA lv_classname TYPE string.
            DATA lv_fm TYPE string.

    TRY.

        TRY.
            
            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            
            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val  = result
                      sub  = `}`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `{`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `'`
                      with = `0`
                      occ  = 0 ).

  ENDMETHOD.


  METHOD uuid_get_c32.
    DATA uuid TYPE c LENGTH 32.
            DATA lv_classname TYPE string.
            DATA lv_fm TYPE string.

    TRY.

        TRY.
            
            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            
            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
