function received_data = Receiver( ...
    pam_levels, ...
    hadamard_size, ...
    input_data)
    
    log2_pam_levels = log2(pam_levels);
    max_number_bits = log2(hadamard_size) + log2_pam_levels;

    x_len = length(input_data) / max_number_bits;
    x = zeros(1, x_len);
    for i = 1 : x_len
        x(i) = binaryVectorToDecimal( ...
            input_data(max_number_bits * (i-1) + 1 : max_number_bits * i));
    end
    
    pam_out = zeros(1, x_len * (hadamard_size - 1) / hadamard_size);
    for i = 1 : x_len / hadamard_size
        offset_vector = ones(1, hadamard_size);
        offset_vector(1) = 1 - hadamard_size;
        u = x * hadamard(hadamard_size) / hadamard_size + offset_vector / 2;
        pam_out((i-1)*(hadamard_size-1) + 1 : i*(hadamard_size-1)) = ...
            u(2 : hadamard_size);
    end
    binary_data = char(strjoin(string(dec2bin(pam_out, log2_pam_levels)), ''));
    bin_tmp = reshape(char(binary_data), length(binary_data), []);
    received_data = bin2dec(bin_tmp)';
end