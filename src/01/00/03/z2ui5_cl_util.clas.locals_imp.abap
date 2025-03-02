CLASS lcl_range_to_sql DEFINITION
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS: BEGIN OF signs,
                 including TYPE string VALUE 'I',
                 excluding TYPE string VALUE 'E',
               END OF signs.

    CONSTANTS: BEGIN OF options,
                 equal                TYPE string VALUE 'EQ',
                 not_equal            TYPE string VALUE 'NE',
                 between              TYPE string VALUE 'BT',
                 not_between          TYPE string VALUE 'NB',
                 contains_pattern     TYPE string VALUE 'CP',
                 not_contains_pattern TYPE string VALUE 'NP',
                 greater_than         TYPE string VALUE 'GT',
                 greater_equal        TYPE string VALUE 'GE',
                 less_equal           TYPE string VALUE 'LE',
                 less_than            TYPE string VALUE 'LT',
               END OF options.

    METHODS constructor
      IMPORTING
        iv_fieldname TYPE clike
        ir_range     TYPE REF TO data.

    METHODS get_sql
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mv_fieldname TYPE string.
    DATA mr_range     TYPE REF TO data.

    CLASS-METHODS quote
      IMPORTING
        val        TYPE clike
      RETURNING
        VALUE(out) TYPE string.

ENDCLASS.


CLASS lcl_range_to_sql IMPLEMENTATION.
  METHOD constructor.

    mr_range = ir_range.
    mv_fieldname = |{ to_upper( iv_fieldname ) }|.

  ENDMETHOD.

  METHOD get_sql.

    FIELD-SYMBOLS <lt_range> TYPE STANDARD TABLE.
    DATA temp1 TYPE xsdboolean.
    FIELD-SYMBOLS <ls_range_item> TYPE ANY.
      FIELD-SYMBOLS <lv_sign> TYPE any.
      FIELD-SYMBOLS <lv_option> TYPE any.
      FIELD-SYMBOLS <lv_low> TYPE any.
      FIELD-SYMBOLS <lv_high> TYPE any.

    ASSIGN me->mr_range->* TO <lt_range>.

    
    temp1 = boolc( <lt_range> IS INITIAL ).
    IF temp1 = abap_true.
      RETURN.
    ENDIF.

    result = `(`.

    
    LOOP AT <lt_range> ASSIGNING <ls_range_item>.

      
      ASSIGN COMPONENT 'SIGN' OF STRUCTURE <ls_range_item> TO <lv_sign>.
      
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <ls_range_item> TO <lv_option>.
      
      ASSIGN COMPONENT 'LOW' OF STRUCTURE <ls_range_item> TO <lv_low>.
      
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <ls_range_item> TO <lv_high>.

      IF sy-tabix <> 1.
        result = |{ result } OR|.
      ENDIF.

      IF <lv_sign> = signs-excluding.
        result = |{ result } NOT|.
      ENDIF.

      result = |{ result } { me->mv_fieldname }|.

      CASE <lv_option>.
        WHEN options-equal OR
             options-not_equal OR
             options-greater_than OR
             options-greater_equal OR
             options-less_equal OR
             options-less_than.
          result = |{ result } { <lv_option> } { quote( <lv_low> ) }|.

        WHEN options-between.
          result = |{ result } BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-not_between.
          result = |{ result } NOT BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } LIKE { quote( <lv_low> ) }|.

        WHEN options-not_contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } NOT LIKE { quote( <lv_low> ) }|.
      ENDCASE.
    ENDLOOP.

    result = |{ result } )|.

  ENDMETHOD.

  METHOD quote.
    out = |'{ replace( val  = val
                       sub  = `'`
                       with = `''`
                       occ  = 0 ) }'|.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_msp_mapper DEFINITION
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        is_msg        TYPE z2ui5_cl_util=>ty_s_msg
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_msg.

    CLASS-METHODS msg_get
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

ENDCLASS.

CLASS lcl_msp_mapper IMPLEMENTATION.

  METHOD msg_get.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE z2ui5_cl_util=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp54 TYPE z2ui5_cl_util=>ty_s_msg.
        DATA ls_result LIKE temp54.
        DATA temp55 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp55.
          DATA lv_name TYPE string.
          FIELD-SYMBOLS <comp> TYPE any.
            DATA temp56 TYPE REF TO cx_root.
            DATA lx LIKE temp56.
            DATA lt_attri_o TYPE abap_attrdescr_tab.
            DATA temp57 LIKE LINE OF lt_attri_o.
            DATA ls_attri_o LIKE REF TO temp57.
            DATA obj TYPE REF TO object.
                DATA lr_tab TYPE REF TO data.
                FIELD-SYMBOLS <tab2> TYPE data.
                DATA lt_tab2 TYPE z2ui5_cl_util=>ty_t_msg.
                    DATA lx2 TYPE REF TO cx_root.
          DATA temp58 TYPE z2ui5_cl_util=>ty_s_msg.
    lv_kind = z2ui5_cl_util=>rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.
        
        ASSIGN val TO <tab>.
        
        LOOP AT <tab> ASSIGNING <row>.
          
          lt_tab = msg_get( <row> ).
          INSERT LINES OF lt_tab INTO TABLE result.
        ENDLOOP.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        
        lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).

        
        CLEAR temp54.
        
        ls_result = temp54.
        
        
        LOOP AT lt_attri REFERENCE INTO ls_attri.
          
          lv_name = |VAL-{ ls_attri->name }|.
          
          ASSIGN (lv_name) TO <comp>.

          IF ls_attri->name = 'ITEM'.
            lt_tab = msg_get( <comp> ).
            INSERT LINES OF lt_tab INTO TABLE result.
            RETURN.
          ELSE.
            ls_result = msg_map( name = ls_attri->name val = <comp> is_msg = ls_result ).
          ENDIF.

        ENDLOOP.
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL.
          MESSAGE ID ls_result-id TYPE 'I' NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        TRY.
            
            temp56 ?= val.
            
            lx = temp56.
            CLEAR ls_result.
            ls_result-type = 'E'.
            ls_result-text = lx->get_text( ).
            
            lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
            
            
            LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                 WHERE visibility = 'U'.
              lv_name = |VAL->{ ls_attri_o->name }|.
              ASSIGN (lv_name) TO <comp>.
              ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
            ENDLOOP.
            INSERT ls_result INTO TABLE result.
          CATCH cx_root.

            
            obj = val.

            TRY.

                
                CREATE DATA lr_tab TYPE ('if_bali_log=>ty_item_table').
                
                ASSIGN lr_tab->* TO <tab2>.

                CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
                  RECEIVING
                    item_table = <tab2>.

                
                lt_tab2 = msg_get( <tab2> ).
                INSERT LINES OF lt_tab2 INTO TABLE result.

              CATCH cx_root.

                TRY.

                    CREATE DATA lr_tab TYPE ('BAPIRETTAB').
                    ASSIGN lr_tab->* TO <tab2>.

                    CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
                      RECEIVING
                        rt_bapiret = <tab2>.

                    lt_tab2 = msg_get( <tab2> ).
                    INSERT LINES OF lt_tab2 INTO TABLE result.

                    
                  CATCH cx_root INTO lx2.


                    lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
                    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                         WHERE visibility = 'U'.
                      lv_name = |OBJ->{ ls_attri_o->name }|.
                      ASSIGN (lv_name) TO <comp>.
                      ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
                    ENDLOOP.
                    INSERT ls_result INTO TABLE result.

                ENDTRY.
            ENDTRY.
        ENDTRY.

      WHEN OTHERS.

        IF z2ui5_cl_util=>rtti_check_clike( val ) IS NOT INITIAL.
          
          CLEAR temp58.
          temp58-text = val.
          INSERT temp58
                 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_map.

    result = is_msg.
    CASE name.
      WHEN 'ID' OR 'MSGID'.
        result-id = val.
      WHEN 'NO' OR 'NUMBER' OR 'MSGNO'.
        result-no = val.
      WHEN 'MESSAGE' OR 'TEXT'.
        result-text = val.
      WHEN 'TYPE' OR 'MSGTY'.
        result-type = val.
      WHEN 'MESSAGE_V1' OR 'MSGV1' OR 'V1'.
        result-v1 = val.
      WHEN 'MESSAGE_V2' OR 'MSGV2' OR 'V2'.
        result-v2 = val.
      WHEN 'MESSAGE_V3' OR 'MSGV3' OR 'V3'.
        result-v3 = val.
      WHEN 'MESSAGE_V4' OR 'MSGV4' OR 'V4'.
        result-v4 = val.
      WHEN 'TIME_STMP'.
        result-timestampl = val.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
