global precompile_bn_mul:
    // stack: address, retdest, new_ctx, (old stack)
    %pop2
    // stack: new_ctx, (old stack)
    DUP1
    SET_CONTEXT
    %checkpoint %mstore_context_metadata(@CTX_METADATA_CHECKPOINT) // Checkpoint and store it in context metadata.
    // stack: (empty)
    PUSH 0x100000000 // = 2^32 (is_kernel = true)
    // stack: kexit_info

    %charge_gas_const(@BN_MUL_GAS)

    // Load x, y, n from the call data using `mload_packing`.
    PUSH bn_mul_return
    // stack: bn_mul_return, kexit_info
    %stack () -> (@SEGMENT_CALLDATA, 64, 32)
    GET_CONTEXT
    // stack: ctx, @SEGMENT_CALLDATA, 64, 32, bn_mul_return, kexit_info
    %mload_packing
    // stack: n, bn_mul_return, kexit_info
    %stack () -> (@SEGMENT_CALLDATA, 32, 32)
    GET_CONTEXT
    // stack: ctx, @SEGMENT_CALLDATA, 32, 32, n, bn_mul_return, kexit_info
    %mload_packing
    // stack: y, n, bn_mul_return, kexit_info
    %stack () -> (@SEGMENT_CALLDATA, 0, 32)
    GET_CONTEXT
    // stack: ctx, @SEGMENT_CALLDATA, 0, 32, y, n, bn_mul_return, kexit_info
    %mload_packing
    // stack: x, y, n, bn_mul_return, kexit_info
    %jump(bn_mul)
bn_mul_return:
    // stack: Px, Py, kexit_info
    DUP2 %eq_const(@U256_MAX) // bn_mul returns (U256_MAX, U256_MAX) on bad input.
    DUP2 %eq_const(@U256_MAX) // bn_mul returns (U256_MAX, U256_MAX) on bad input.
    MUL // Cheaper than AND
    %jumpi(fault_exception)
    // stack: Px, Py, kexit_info

    // Store the result (Px, Py) to the parent's return data using `mstore_unpacking`.
    %mstore_parent_context_metadata(@CTX_METADATA_RETURNDATA_SIZE, 64)
    %mload_context_metadata(@CTX_METADATA_PARENT_CONTEXT)
    %stack (parent_ctx, Px, Py) -> (parent_ctx, @SEGMENT_RETURNDATA, 0, Px, 32, bn_mul_contd6, parent_ctx, Py)
    %jump(mstore_unpacking)
bn_mul_contd6:
    POP
    %stack (parent_ctx, Py) -> (parent_ctx, @SEGMENT_RETURNDATA, 32, Py, 32, pop_and_return_success)
    %jump(mstore_unpacking)
