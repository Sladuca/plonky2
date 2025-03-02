global precompile_id:
    // stack: address, retdest, new_ctx, (old stack)
    %pop2
    // stack: new_ctx, (old stack)
    DUP1
    SET_CONTEXT
    %checkpoint %mstore_context_metadata(@CTX_METADATA_CHECKPOINT) // Checkpoint and store it in context metadata.
    // stack: (empty)
    PUSH 0x100000000 // = 2^32 (is_kernel = true)
    // stack: kexit_info

    %calldatasize
    %num_bytes_to_num_words
    // stack: data_words_len, kexit_info
    %mul_const(@ID_DYNAMIC_GAS)
    PUSH @ID_STATIC_GAS
    ADD
    // stack: gas, kexit_info
    %charge_gas

    // Simply copy the call data to the parent's return data.
    %calldatasize
    DUP1 %mstore_parent_context_metadata(@CTX_METADATA_RETURNDATA_SIZE)
    GET_CONTEXT
    %mload_context_metadata(@CTX_METADATA_PARENT_CONTEXT)
    %stack (parent_ctx, ctx, size) ->
        (
        parent_ctx, @SEGMENT_RETURNDATA, 0,  // DST
        ctx, @SEGMENT_CALLDATA, 0,  // SRC
        size, id_contd              // count, retdest
        )
    %jump(memcpy)

id_contd:
    // stack: kexit_info
    %leftover_gas
    // stack: leftover_gas
    PUSH 1 // success
    %jump(terminate_common)
