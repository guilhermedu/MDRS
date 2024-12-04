function [PLD, PLV, APDD, APDV, MPDD, MPDV, TT] = Sim3A(lambda, C, f, P, n, b)
% INPUT PARAMETERS:
% lambda - packet rate (packets/sec)
% C      - link bandwidth (Mbps)
% f      - queue size (Bytes)
% P      - number of packets (stopping criterion)
% n      - number of VoIP packet flows
% b      - bit error rate (BER)

% OUTPUT PARAMETERS:
% PLD  - packet loss of data packets (%)
% PLV  - packet loss of VoIP packets (%)
% APDD - average packet delay for data packets (milliseconds)
% APDV - average packet delay for VoIP packets (milliseconds)
% MPDD - maximum packet delay for data packets (milliseconds)
% MPDV - maximum packet delay for VoIP packets (milliseconds)
% TT   - transmitted throughput (Mbps)

% Events:
ARRIVAL = 0;       % Arrival of a packet            
DEPARTURE = 1;     % Departure of a packet

% Packet Types:
Dados = 0;         % Data packets
Voip = 1;          % VoIP packets

% State variables:
STATE = 0;         % 0 - connection is free, 1 - connection is occupied
QUEUEOCCUPATION = 0; % Occupation of the queue (in Bytes)
QUEUE = [];        % Queue to store packet size and arrival time

% Statistical Counters:
TOTALPACKETSD = 0;   % Total data packets arrived
TOTALPACKETSV = 0;   % Total VoIP packets arrived
LOSTPACKETSD = 0;    % Data packets lost due to buffer overflow
LOSTPACKETSV = 0;    % VoIP packets lost due to buffer overflow
TRANSPACKETSD = 0;   % Data packets transmitted
TRANSPACKETSV = 0;   % VoIP packets transmitted
TRANSBYTESD = 0;     % Total Bytes of transmitted data packets
TRANSBYTESV = 0;     % Total Bytes of transmitted VoIP packets
DELAYSD = 0;         % Total delay of transmitted data packets
DELAYSV = 0;         % Total delay of transmitted VoIP packets
MAXDELAYD = 0;       % Maximum delay for data packets
MAXDELAYV = 0;       % Maximum delay for VoIP packets

% Initialize simulation clock:
Clock = 0;

% Initialize event list with the first ARRIVAL event:
tmp = Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];

% Add VoIP packet arrival events:
for i = 1:n
    tmp = unifrnd(0, 0.02); % Uniform distribution between 0 ms and 20 ms for VoIP
    EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, Voip];
end

% Simulation loop:
while (TRANSPACKETSD + TRANSPACKETSV) < P
    EventList = sortrows(EventList, 2);  % Order EventList by time
    Event = EventList(1, 1);              % Get first event
    Clock = EventList(1, 2);              % Time of the event
    PacketSize = EventList(1, 3);         % Packet size
    ArrInstant = EventList(1, 4);         % Arrival time
    PacketType = EventList(1, 5);         % Packet type (Dados/Voip)
    EventList(1, :) = [];                 % Remove the processed event
    
    switch Event
        case ARRIVAL
            if PacketType == Dados
                TOTALPACKETSD = TOTALPACKETSD + 1;
                tmp = Clock + exprnd(1/lambda);
                EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];
                if STATE == 0
                    STATE = 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, Dados];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE = [QUEUE; PacketSize, Clock, Dados];
                        QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSD = LOSTPACKETSD + 1;
                    end
                end
            else
                TOTALPACKETSV = TOTALPACKETSV + 1;
                tmp = Clock + unifrnd(0.016, 0.024);  % VoIP inter-arrival time
                EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, Voip];
                if STATE == 0
                    STATE = 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, Voip];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE = [QUEUE; PacketSize, Clock, Voip];
                        QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSV = LOSTPACKETSV + 1;
                    end
                end
            end
        
        case DEPARTURE
            if rand() < (1 - b)^(PacketSize*8) % Simulate packet loss due to bit errors
                if PacketType == Dados
                    TRANSBYTESD = TRANSBYTESD + PacketSize;
                    DELAYSD = DELAYSD + (Clock - ArrInstant);
                    if (Clock - ArrInstant) > MAXDELAYD
                        MAXDELAYD = Clock - ArrInstant;
                    end
                    TRANSPACKETSD = TRANSPACKETSD + 1;
                else
                    TRANSBYTESV = TRANSBYTESV + PacketSize;
                    DELAYSV = DELAYSV + (Clock - ArrInstant);
                    if (Clock - ArrInstant) > MAXDELAYV
                        MAXDELAYV = Clock - ArrInstant;
                    end
                    TRANSPACKETSV = TRANSPACKETSV + 1;
                end
            else
                if PacketType == Dados
                    LOSTPACKETSD = LOSTPACKETSD + 1;
                else
                    LOSTPACKETSV = LOSTPACKETSV + 1;
                end
            end

            if QUEUEOCCUPATION > 0
                EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1, 1)/(C*10^6), QUEUE(1, 1), QUEUE(1, 2), QUEUE(1, 3)];
                QUEUEOCCUPATION = QUEUEOCCUPATION - QUEUE(1, 1);
                QUEUE(1, :) = [];
            else
                STATE = 0;
            end
    end
end

% Performance parameters:
PLD = 100 * LOSTPACKETSD / TOTALPACKETSD; % Packet loss for data packets (%)
PLV = 100 * LOSTPACKETSV / TOTALPACKETSV; % Packet loss for VoIP packets (%)
APDD = 1000 * DELAYSD / TRANSPACKETSD;    % Average delay for data packets (ms)
APDV = 1000 * DELAYSV / TRANSPACKETSV;    % Average delay for VoIP packets (ms)
MPDD = 1000 * MAXDELAYD;                  % Maximum delay for data packets (ms)
MPDV = 1000 * MAXDELAYV;                  % Maximum delay for VoIP packets (ms)
TT = 1e-6 * (TRANSBYTESD + TRANSBYTESV) * 8 / Clock; % Transmitted throughput (Mbps)

end

function out = GeneratePacketSize()
    aux = rand();
    aux2 = [65:109, 111:1517];
    if aux <= 0.19
        out = 64;
    elseif aux <= 0.19 + 0.23
        out = 110;
    elseif aux <= 0.19 + 0.23 + 0.17
        out = 1518;
    else
        out = aux2(randi(length(aux2)));
    end
end
