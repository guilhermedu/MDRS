lambda_Values = [1500, 1600, 1700, 1800, 1900];  % packet rate (packets/sec)
C = 10;         % link bandwidth (Mbps)
f = 10000;      % queue size (Bytes)
P = 100000;     % number of packets (stopping criterion)
b = 10^-4;      % bit error rate
alfa = 0.1;     % 90% confidence interval
N = 20;         % number of simulations

PL_mean = zeros(1, length(lambda_Values)); 
PL_term = zeros(1, length(lambda_Values));
APD_mean = zeros(1, length(lambda_Values)); 
APD_term = zeros(1, length(lambda_Values));

% Simulações para cada lambda
for i = 1:length(lambda_Values)
    lambda = lambda_Values(i);
    
    disp(['Simulating for lambda = ', num2str(lambda)]);    

    PL = zeros(1, N);
    APD = zeros(1, N);
    
    for it = 1:N
        [PL(it), APD(it)] = Sim2(lambda, C, f, P, b);  % Capturar apenas os valores PL e APD
    end

    % Média e intervalo de confiança para PL
    PL_mean(i) = mean(PL);
    PL_term(i) = norminv(1 - alfa/2) * sqrt(var(PL) / N);  % Cálculo do termo de intervalo de confiança para PL
    
    % Média e intervalo de confiança para APD
    APD_mean(i) = mean(APD);
    APD_term(i) = norminv(1 - alfa/2) * sqrt(var(APD) / N);  % Cálculo do termo de intervalo de confiança para APD
end    

% Gráfico de barras para PL (Packet Loss) com intervalos de confiança
figure;
subplot(1, 2, 1);
bar(lambda_Values, PL_mean);
hold on;
er = errorbar(lambda_Values, PL_mean, PL_term, PL_term);  % Adicionando barras de erro
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('λ (packets/second)');
ylabel('Packet Loss (%)');
title('Packet Loss', 'FontSize', 12);
grid on;

% Gráfico de barras para APD (Average Packet Delay) com intervalos de confiança
subplot(1, 2, 2);
bar(lambda_Values, APD_mean);
hold on;
er = errorbar(lambda_Values, APD_mean, APD_term, APD_term);  % Adicionando barras de erro
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('λ (packets/second)');
ylabel('Average Packet Delay (ms)');
title('Average Packet Delay', 'FontSize', 12);
grid on;
