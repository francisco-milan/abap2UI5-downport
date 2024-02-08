CLASS z2ui5_cl_core_action DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mo_http_post TYPE REF TO z2ui5_cl_core_http_post.
    DATA mo_app       TYPE REF TO z2ui5_cl_core_app.

    DATA ms_actual TYPE z2ui5_if_core_types=>ty_s_actual.
    DATA ms_next   TYPE z2ui5_if_core_types=>ty_s_next.

    METHODS factory_system_startup
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_system_error
      IMPORTING
        ix            TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_first_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_by_frontend
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS factory_stack_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_action.

    METHODS constructor
      IMPORTING
        val TYPE REF TO z2ui5_cl_core_http_post.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_action IMPLEMENTATION.


  METHOD constructor.

    mo_http_post = val.
    CREATE OBJECT mo_app.

  ENDMETHOD.


  METHOD factory_by_frontend.

    CREATE OBJECT result EXPORTING VAL = mo_http_post.
    result->mo_app = z2ui5_cl_core_app=>db_load( mo_http_post->ms_request-s_frontend-id ).

    result->mo_app->ms_draft-id      = z2ui5_cl_util=>uuid_get_c32( ).
    result->mo_app->ms_draft-id_prev = mo_http_post->ms_request-s_frontend-id.
    result->ms_actual-view           = mo_http_post->ms_request-s_frontend-view.

    result->mo_app->model_json_parse(
        view          = mo_http_post->ms_request-s_frontend-view
        io_json_model = mo_http_post->ms_request-o_model ).

    result->ms_actual-event              = mo_http_post->ms_request-s_frontend-event.
    result->ms_actual-t_event_arg        = mo_http_post->ms_request-s_frontend-t_event_arg.
    result->ms_actual-check_on_navigated = abap_false.

  ENDMETHOD.


  METHOD factory_first_start.
        DATA temp1 TYPE REF TO z2ui5_if_app.
        DATA li_app LIKE temp1.
        DATA x TYPE REF TO cx_root.

    TRY.
        CREATE OBJECT result EXPORTING VAL = mo_http_post.
        result->mo_app->ms_draft-id = z2ui5_cl_util=>uuid_get_c32( ).

        CREATE OBJECT result->mo_app->mo_app TYPE (mo_http_post->ms_request-s_control-app_start).

        
        temp1 ?= result->mo_app->mo_app.
        
        li_app = temp1.
        li_app->id_draft = result->mo_app->ms_draft-id.

        result->ms_actual-check_on_navigated = abap_true.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = `App with name ` && mo_http_post->ms_request-s_control-app_start && ` not found...`
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD factory_stack_call.


    DATA temp2 TYPE string.
        DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    IF ms_next-o_app_call->id_draft IS INITIAL.
      temp2 = z2ui5_cl_util=>uuid_get_c32( ).
    ELSE.
      temp2 = ms_next-o_app_call->id_draft.
    ENDIF.
    ms_next-o_app_call->id_draft = temp2.

    CREATE OBJECT result EXPORTING VAL = mo_http_post.
    result->mo_app->mo_app               = ms_next-o_app_call.
    result->mo_app->ms_draft-id          = ms_next-o_app_call->id_draft.
    result->mo_app->ms_draft-id_prev     = mo_app->ms_draft-id.
    result->mo_app->ms_draft-id_prev_app = mo_app->ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set                = ms_next-s_set.

    TRY.
        
        lo_app = z2ui5_cl_core_app=>db_load( ms_next-o_app_call->id_draft ).
        result->mo_app->mo_app   = lo_app->mo_app.
        result->mo_app->mt_attri = lo_app->mt_attri.

      CATCH cx_root.
    ENDTRY.

    result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id.
    mo_app->db_save( ).

  ENDMETHOD.


  METHOD factory_stack_leave.

    DATA temp3 TYPE string.
        DATA lo_db TYPE REF TO z2ui5_cl_core_draft_srv.
        DATA ls_draft TYPE z2ui5_if_types=>ty_s_draft.
    IF ms_next-o_app_leave->id_draft IS INITIAL.
      temp3 = z2ui5_cl_util=>uuid_get_c32( ).
    ELSE.
      temp3 = ms_next-o_app_leave->id_draft.
    ENDIF.
    ms_next-o_app_leave->id_draft = temp3.

    CREATE OBJECT result EXPORTING VAL = mo_http_post.
    result->mo_app->mo_app               = ms_next-o_app_leave.
    result->mo_app->ms_draft-id          = ms_next-o_app_leave->id_draft.
    result->mo_app->ms_draft-id_prev     = mo_app->ms_draft-id.
    result->mo_app->ms_draft-id_prev_app = mo_app->ms_draft-id.
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-s_set                = ms_next-s_set.

    TRY.
        
        CREATE OBJECT lo_db TYPE z2ui5_cl_core_draft_srv.
        
        ls_draft = lo_db->read_info( result->mo_app->ms_draft-id ).
        result->mo_app->ms_draft-id_prev_app_stack = ls_draft-id_prev_app_stack.

      CATCH cx_root.
        result->mo_app->ms_draft-id_prev_app_stack = mo_app->ms_draft-id_prev_app_stack.
    ENDTRY.

    mo_app->db_save( ).

  ENDMETHOD.


  METHOD factory_system_error.

    CREATE OBJECT result EXPORTING VAL = mo_http_post.

    result->mo_app->ms_draft-id          = z2ui5_cl_util=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->ms_next-o_app_call           = z2ui5_cl_core_app_error=>factory( ix ).

    result = result->factory_stack_call( ).

  ENDMETHOD.


  METHOD factory_system_startup.
    DATA temp4 TYPE REF TO z2ui5_if_app.
    DATA li_app LIKE temp4.

    CREATE OBJECT result EXPORTING VAL = mo_http_post.

    result->mo_app->ms_draft-id          = z2ui5_cl_util=>uuid_get_c32( ).
    result->ms_actual-check_on_navigated = abap_true.
    result->mo_app->mo_app               = z2ui5_cl_core_app_startup=>factory( ).

    
    temp4 ?= result->mo_app->mo_app.
    
    li_app = temp4.
    li_app->id_draft = result->mo_app->ms_draft-id.

  ENDMETHOD.
ENDCLASS.
