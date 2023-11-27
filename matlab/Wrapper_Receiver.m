function received_data = Wrapper_Receiver( ...
    pam_levels, ...
    hadamard_size, ...
    transmited_data)

    status = CRC_Decoder(transmited_data);
    if status == 0 % correct data
        received_data = Receiver(pam_levels, hadamard_size, ...
            transmited_data(1:end-4));
    else % error
        output_len = log2(pam_levels) * (hadamard_size-1);
        received_data = zeros(1, output_len);
    end
end