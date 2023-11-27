%% phase 2 Li-Fi
clear;
clc;
close all;

hadamard_size = 16;
pam_levels = 8;
input_len = log2(pam_levels) * (hadamard_size-1);

file = fopen('EncodedData.txt','w');
fileIn = fopen('DecodedData.txt', 'w');
number_of_tests = 100;
for i = 1:number_of_tests
%     input_data = [1, 0, 1, 1, 1, 1];
    input_data = randi([0 1], 1,  input_len);
    
    transmited_packet = Wrapper_Transmiter(pam_levels, ...
        hadamard_size, input_data);
    received_data = Wrapper_Receiver(pam_levels, ...
        hadamard_size, transmited_packet);
    
    if sum(input_data ~= received_data) == 0
        disp('all tests passed');
    else
        disp('error : ');
        disp(transmited_data);
        disp(received_data);
    end
    EncodedData = strjoin(string( ...
        dec2bin(transmited_packet(1:end-4))), '');
    fwrite(file, EncodedData + newline);
    DecodedData = strjoin(string(dec2bin(received_data)), '');
    fwrite(fileIn, DecodedData + newline);
end
fclose(file);
fclose(fileIn);