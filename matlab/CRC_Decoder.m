function status = CRC_Decoder(packet)
    key = [1 0 0 1 1];
    len = length(packet);
    for i = 1:len
        if packet(1) == 1
            packet(1:5) = xor(packet(1:5), key);
        end
        packet = packet(2:end);
    end
    if sum(abs(packet)) == 0
        status = 0; % (Done)
    else
        status = 1; % (Error)
    end
end