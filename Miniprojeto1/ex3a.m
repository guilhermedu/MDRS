% Definição dos parâmetros
lambda = 1500;            % Taxa de chegada de pacotes (pps)
C = 10;                   % Largura de banda do link (Mbps)
f = 10000;                  % Tamanho da fila (Bytes)
P = 100000;               % Critério de parada (número de pacotes)
n_values = [10, 20, 30, 40]; % Valores de n (fluxos VoIP)
alfa = 0.1;               % Intervalo de confiança de 90%
N = 20;                   % Número de execuções para cada valor de n

% Inicialização das variáveis para armazenar os resultados
PLD_mean = zeros(1, length(n_values));
PLV_mean = zeros(1, length(n_values));
APDD_mean = zeros(1, length(n_values));
APDV_mean = zeros(1, length(n_values));

PLD_term = zeros(1, length(n_values));
PLV_term = zeros(1, length(n_values));
APDD_term = zeros(1, length(n_values));
APDV_term = zeros(1, length(n_values));

% Loop pelas diferentes quantidades de fluxos VoIP
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulando para n = ', num2str(n), ' fluxos VoIP']);
    
    % Inicializando os vetores para armazenar os resultados de cada execução
    PLD = zeros(1, N);
    PLV = zeros(1, N);
    APDD = zeros(1, N);
    APDV = zeros(1, N);
    
    % Loop para rodar a simulação 20 vezes
    for j = 1:N
        [PLD(j), PLV(j), APDD(j), APDV(j), ~, ~, ~] = Sim3(lambda, C, f, P, n);
    end
    
    % Cálculo da média e dos intervalos de confiança para cada parâmetro
    PLD_mean(i) = mean(PLD);
    PLD_term(i) = norminv(1 - alfa/2) * sqrt(var(PLD) / N);
    
    PLV_mean(i) = mean(PLV);
    PLV_term(i) = norminv(1 - alfa/2) * sqrt(var(PLV) / N);
    
    APDD_mean(i) = mean(APDD);
    APDD_term(i) = norminv(1 - alfa/2) * sqrt(var(APDD) / N);
    
    APDV_mean(i) = mean(APDV);
    APDV_term(i) = norminv(1 - alfa/2) * sqrt(var(APDV) / N);
    
    % Imprimir os resultados após o loop das simulações para cada n
    fprintf('\nResultados para n = %d fluxos VoIP:\n', n);
    fprintf('PLD  (Data Loss): %.2e +- %.2e\n', PLD_mean(i), PLD_term(i));
    fprintf('PLV  (VoIP Loss): %.2e +- %.2e\n', PLV_mean(i), PLV_term(i));
    fprintf('APDD (Avg Delay Data): %.2e +- %.2e ms\n', APDD_mean(i), APDD_term(i));
    fprintf('APDV (Avg Delay VoIP): %.2e +- %.2e ms\n', APDV_mean(i), APDV_term(i));
end

% Gráficos de perda de pacotes (PLD e PLV)
figure;
subplot(1, 2, 1);
bar(n_values, PLD_mean);
hold on;
er = errorbar(n_values, PLD_mean, PLD_term, PLD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Número de Fluxos VoIP (n)');
ylabel('Perda de Pacotes (%) - Data');
title('Perda de Pacotes (Data)');
grid on;

subplot(1, 2, 2);
bar(n_values, PLV_mean);
hold on;
er = errorbar(n_values, PLV_mean, PLV_term, PLV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Número de Fluxos VoIP (n)');
ylabel('Perda de Pacotes (%) - VoIP');
title('Perda de Pacotes (VoIP)');
grid on;

% Gráficos de atraso médio (APDD e APDV)
figure;
subplot(1, 2, 1);
bar(n_values, APDD_mean);
hold on;
er = errorbar(n_values, APDD_mean, APDD_term, APDD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Número de Fluxos VoIP (n)');
ylabel('Atraso Médio (ms) - Data');
title('Atraso Médio de Pacotes (Data)');
grid on;

subplot(1, 2, 2);
bar(n_values, APDV_mean);
hold on;
er = errorbar(n_values, APDV_mean, APDV_term, APDV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Número de Fluxos VoIP (n)');
ylabel('Atraso Médio (ms) - VoIP');
title('Atraso Médio de Pacotes (VoIP)');
grid on;
