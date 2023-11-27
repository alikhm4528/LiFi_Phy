function crc = CRC_Encoder(packet)
    key = [1 0 0 1 1];
    packet = [packet, zeros(1, 4)];
    len = length(packet);
    for i = 1:len-4
        if packet(1) == 1
            packet(1:5) = xor(packet(1:5), key);
        end
        packet = packet(2:end);
    end
    crc = packet;
end