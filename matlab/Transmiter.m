function encoded_data = Transmiter( ...
    pam_levels, ...
    hadamard_size, ...
    input_data)

    log2_pam_levels = log2(pam_levels);
    pam_data_size = length(input_data) / log2_pam_levels;
    pam_data = zeros(1, pam_data_size);
    for i = 1 : pam_data_size
        pam_data(i) = binaryVectorToDecimal( ...
            input_data(log2_pam_levels*(i-1) + 1 : log2_pam_levels*i));
    end
    u = zeros(1, hadamard_size);
    u(1) = 0;
    offset_vector = ones(1, hadamard_size);
    offset_vector(1) = 0;

    for i = 1 : pam_data_size / (hadamard_size-1)
        u(2 : hadamard_size) = ...
            pam_data((i-1)*(hadamard_size-1)+1 : i*(hadamard_size-1));
%         disp(u);
        x = u * hadamard(hadamard_size) + hadamard_size/2 * offset_vector;
        % The message which is ready to transmit. This message will be coded in the following.
        dc_removal_signal = x - min(x);
        % 4 shows the nuber of bits. This parameter must set in each case.
        % Convert binary number to binary string
        max_number_bits = log2(hadamard_size) + log2_pam_levels;
        binary_dc_removal_signal_str = ...
            dec2bin(dc_removal_signal, max_number_bits);
        encoded_data_str = [];
        for j = 1:hadamard_size
            encoded_data_str = [encoded_data_str, ...
                binary_dc_removal_signal_str(j, :)];
        end
        % These bits are the final encoded data which are ready to be transmitted.
        encoded_data = str2num(encoded_data_str(:))';
    end
end