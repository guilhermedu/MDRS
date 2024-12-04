function [PLD,PLV,APDD,APDV,MPDD,MPDV,TT] = Sim3(lambda,C,f,P,n)
% INPUT PARAMETERS:
  %lambda = 1800;%packet rate (packets/sec)
  %C      = 10;%link bandwidth (Mbps)
  %f      = 1000000;%queue size (Bytes)
  %P      = 1000;%number of packets (stopping criterium)
  %n      =20;%VoIp packet flows
% OUTPUT PARAMETERS:
%  PL   - packet loss (%)
%  PLV - Packet Loss of VoIp packets(%)
%  APD  - average packet delay (milliseconds)
%  APDV - average packet of Voip packets(miliseconds)
%  MPD  - maximum packet delay (milliseconds)
%  MPDV - Maximum Delay of Voip packets(miliseconds)
%  TT   - transmitted throughput (Mbps)

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

Dados=0;
Voip=1;

%State variables:
STATE = 0;          % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
QUEUE= [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TOTALPACKETSD= 0;     % No. of packets arrived to the system
TOTALPACKETSV= 0;     
LOSTPACKETSD= 0;      % No. of packets dropped due to buffer overflow
LOSTPACKETSV= 0;
TRANSPACKETSD= 0;     % No. of transmitted packets
TRANSPACKETSV= 0;
TRANSBYTESD= 0;       % Sum of the Bytes of transmitted packets
TRANSBYTESV= 0;
DELAYSD= 0;           % Sum of the delays of transmitted packets
DELAYSV= 0;
MAXDELAYD= 0;         % Maximum delay among all transmitted packets
MAXDELAYV= 0;

% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
tmp= Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];

for i = 1:n
    tmp = unifrnd(0, 0.02);              %packet arrivals is unif distrib between 0 ms and 20 ms
    EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, Voip];
end

    %Similation loop:
    while (TRANSPACKETSD+TRANSBYTESV)<P               % Stopping criterium
        EventList= sortrows(EventList,2);  % Order EventList by time
        Event= EventList(1,1);              % Get first event 
        Clock= EventList(1,2);              %    and all
        PacketSize= EventList(1,3);        %    associated
        ArrInstant= EventList(1,4);    %    parameters.
        PacketType= EventList(1,5);
        EventList(1,:)= [];                 % Eliminate first event
        switch Event
            case ARRIVAL         % If first event is an ARRIVAL
                if PacketType==Dados
                    TOTALPACKETSD= TOTALPACKETSD+1;
                    tmp= Clock + exprnd(1/lambda);
                    EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp, Dados];
                    if STATE==0
                        STATE= 1;
                        EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock,Dados];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            QUEUE= [QUEUE;PacketSize , Clock,Dados];
                            QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                        else
                            LOSTPACKETSD= LOSTPACKETSD + 1;
                        end
                    end
                else
                    TOTALPACKETSV= TRANSPACKETSV +1;
                    tmp = Clock + unifrnd(0.016, 0.024);
                    EventList = [EventList; ARRIVAL,tmp,randi([110,130]),tmp,Voip];
                    if STATE==0
                        STATE=1;
                        EventList = [EventList; DEPARTURE,Clock + 8*PacketSize/(C*10^6),PacketSize,Clock,Voip];
                    else
                        if QUEUEOCCUPATION + PacketSize <= f
                            QUEUE= [QUEUE;PacketSize , Clock,Voip];
                            QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                        else
                            LOSTPACKETSV= LOSTPACKETSV + 1;
                        end
                    end
                end

    
            case DEPARTURE          % If first event is a DEPARTURE
                if(PacketType==Dados)
                    TRANSBYTESD= TRANSBYTESD + PacketSize;
                    DELAYSD= DELAYSD + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYD
                        MAXDELAYD= Clock - ArrInstant;
                    end
                    TRANSPACKETSD= TRANSPACKETSD + 1;
                else
                    TRANSBYTESV= TRANSBYTESV + PacketSize;
                    DELAYSV= DELAYSV + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYV
                        MAXDELAYV= Clock - ArrInstant;
                    end
                    TRANSPACKETSV= TRANSPACKETSV + 1;
                end
                if QUEUEOCCUPATION > 0
                    EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2),QUEUE(1,3)];
                    QUEUEOCCUPATION= QUEUEOCCUPATION - QUEUE(1,1);
                    QUEUE(1,:)= [];
                else
                    STATE= 0;
                end
        end
    end
%Performance parameters determination:
PLD= 100*LOSTPACKETSD/TOTALPACKETSD;  % in percentage
PLV=100*LOSTPACKETSV/TOTALPACKETSV;
APDD= 1000*DELAYSD/TRANSPACKETSD;     % in milliseconds
APDV=1000*DELAYSV/TRANSPACKETSV; 
MPDD= 1000*MAXDELAYD;                % in milliseconds
MPDV= 1000*MAXDELAYV;   
TT= 1e-6*(TRANSBYTESD+TRANSBYTESV)*8/Clock;    % in Mbps

end

function out= GeneratePacketSize()
    aux= rand();
    aux2= [65:109 111:1517];
    if aux <= 0.19
        out= 64;
    elseif aux <= 0.19 + 0.23
        out= 110;
    elseif aux <= 0.19 + 0.23 + 0.17
        out= 1518;
    else
        out = aux2(randi(length(aux2)));
    end
end