function [PLD, PLV, APDD, APDV, MPDD, MPDV, TT] = Sim4(lambda, C, f, P, n)
    % INPUT PARAMETERS are the same as in Sim3

    % Events and State Variables remain the same as Sim3
    ARRIVAL = 0;        
    DEPARTURE = 1;

    Dados = 0;  % Data packet type
    Voip = 1;   % VoIP packet type

    STATE = 0;          
    QUEUEOCCUPATION = 0; 
    QUEUE = [];         

    % Statistical Counters remain the same
    TOTALPACKETSD = 0;
    TOTALPACKETSV = 0;
    LOSTPACKETSD = 0;
    LOSTPACKETSV = 0;
    TRANSPACKETSD = 0;
    TRANSPACKETSV = 0;
    TRANSBYTESD = 0;
    TRANSBYTESV = 0;
    DELAYSD = 0;
    DELAYSV = 0;
    MAXDELAYD = 0;
    MAXDELAYV = 0;

    % Initialize simulation clock
    Clock = 0;
    tmp = Clock + exprnd(1/lambda);
    EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];

    for i = 1:n
        tmp = unifrnd(0, 0.02);  
        EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, Voip];
    end

    % Simulation Loop
    while (TRANSPACKETSD + TRANSPACKETSV) < P   
        EventList = sortrows(EventList, 2);  % Sort events by time
        Event = EventList(1, 1);  
        Clock = EventList(1, 2);  
        PacketSize = EventList(1, 3);  
        ArrInstant = EventList(1, 4);  
        PacketType = EventList(1, 5);  
        EventList(1, :) = [];  % Remove the event after processing
        
        switch Event
            case ARRIVAL  
                if PacketType == Dados
                    TOTALPACKETSD = TOTALPACKETSD + 1;
                    tmp = Clock + exprnd(1/lambda);
                    EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];
                    if STATE == 0
                        STATE = 1;
                        EventList = [EventList; DEPARTURE, Clock + 8 * PacketSize / (C * 1e6), PacketSize, Clock, Dados];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            % Add data packet to the queue
                            QUEUE = [QUEUE; PacketSize, Clock, Dados];
                            QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                            % Sort the queue to prioritize VoIP packets
                            QUEUE = sortrows(QUEUE, 3, 'descend');  % Sort by PacketType, prioritize VoIP
                        else
                            LOSTPACKETSD = LOSTPACKETSD + 1;
                        end
                    end
                else
                    TOTALPACKETSV = TOTALPACKETSV + 1;
                    tmp = Clock + unifrnd(0.016, 0.024);
                    EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, Voip];
                    if STATE == 0
                        STATE = 1;
                        EventList = [EventList; DEPARTURE, Clock + 8 * PacketSize / (C * 1e6), PacketSize, Clock, Voip];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            % Add VoIP packet to the queue
                            QUEUE = [QUEUE; PacketSize, Clock, Voip];
                            QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                            % Sort the queue to prioritize VoIP packets
                            QUEUE = sortrows(QUEUE, 3, 'descend');  % Sort by PacketType, prioritize VoIP
                        else
                            LOSTPACKETSV = LOSTPACKETSV + 1;
                        end
                    end
                end

            case DEPARTURE  
                if PacketType == Dados
                    TRANSBYTESD = TRANSBYTESD + PacketSize;
                    DELAYSD = DELAYSD + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYD
                        MAXDELAYD = Clock - ArrInstant;
                    end
                    TRANSPACKETSD = TRANSPACKETSD + 1;
                else
                    TRANSBYTESV = TRANSBYTESV + PacketSize;
                    DELAYSV = DELAYSV + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYV
                        MAXDELAYV = Clock - ArrInstant;
                    end
                    TRANSPACKETSV = TRANSPACKETSV + 1;
                end
                if QUEUEOCCUPATION > 0
                    % Process the next packet, which is now sorted by priority
                    EventList = [EventList; DEPARTURE, Clock + 8 * QUEUE(1, 1) / (C * 1e6), QUEUE(1, 1), QUEUE(1, 2), QUEUE(1, 3)];
                    QUEUEOCCUPATION = QUEUEOCCUPATION - QUEUE(1, 1);
                    QUEUE(1, :) = [];
                else
                    STATE = 0;
                end
        end
    end

    % Performance Parameters
    PLD = 100 * LOSTPACKETSD / TOTALPACKETSD;
    PLV = 100 * LOSTPACKETSV / TOTALPACKETSV;
    APDD = 1000 * DELAYSD / TRANSPACKETSD;
    APDV = 1000 * DELAYSV / TRANSPACKETSV;
    MPDD = 1000 * MAXDELAYD;
    MPDV = 1000 * MAXDELAYV;
    TT = 1e-6 * (TRANSBYTESD + TRANSBYTESV) * 8 / Clock;

end

function out = GeneratePacketSize()
    aux = rand();
    aux2 = [65:109 111:1517];  % Range of packet sizes
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