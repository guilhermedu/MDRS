% Definição dos parâmetros
lambda = 1500;            % Taxa de chegada de pacotes (pps)
C = 10;                   % Largura de banda do link (Mbps)
f = 1000000;              % Tamanho da fila (Bytes)
P = 100000;               % Critério de parada (número de pacotes)
b = 10^-5;                % Taxa de erro de bits
n_values = [10, 20, 30, 40]; % Valores de n (fluxos VoIP)
alfa = 0.1;               % Intervalo de confiança de 90%
N = 20;                   % Número de execuções para cada valor de n

% Inicialização das variáveis para armazenar os resultados
PLD_mean = zeros(1, length(n_values));
PLV_mean = zeros(1, length(n_values));
APDD_mean = zeros(1, length(n_values));
APDV_mean = zeros(1, length(n_values));
MPDD_mean = zeros(1, length(n_values));
MPDV_mean = zeros(1, length(n_values));
TT_mean = zeros(1, length(n_values));

PLD_term = zeros(1, length(n_values));
PLV_term = zeros(1, length(n_values));
APDD_term = zeros(1, length(n_values));
APDV_term = zeros(1, length(n_values));
MPDD_term = zeros(1, length(n_values));
MPDV_term = zeros(1, length(n_values));
TT_term = zeros(1, length(n_values));

% Loop pelas diferentes quantidades de fluxos VoIP
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulando para n = ', num2str(n), ' fluxos VoIP\n']);
    
    % Inicializando os vetores para armazenar os resultados de cada execução
    PLD = zeros(1, N);
    PLV = zeros(1, N);
    APDD = zeros(1, N);
    APDV = zeros(1, N);
    MPDD = zeros(1, N);
    MPDV = zeros(1, N);
    TT = zeros(1, N);
    
    % Loop para rodar a simulação 20 vezes
    for j = 1:N
        [PLD(j), PLV(j), APDD(j), APDV(j), MPDD(j), MPDV(j), TT(j)] = Sim3A(lambda, C, f, P, n, b);
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
    
    MPDD_mean(i) = mean(MPDD);
    MPDD_term(i) = norminv(1 - alfa/2) * sqrt(var(MPDD) / N);
    
    MPDV_mean(i) = mean(MPDV);
    MPDV_term(i) = norminv(1 - alfa/2) * sqrt(var(MPDV) / N);
    
    TT_mean(i) = mean(TT);
    TT_term(i) = norminv(1 - alfa/2) * sqrt(var(TT) / N);
    
    % Imprimir os resultados após o loop das simulações para cada n
    fprintf('\nResultados para n = %d fluxos VoIP:\n', n);
    fprintf('PLD  (Data Loss): %.2e +- %.2e\n', PLD_mean(i), PLD_term(i));
    fprintf('PLV  (VoIP Loss): %.2e +- %.2e\n', PLV_mean(i), PLV_term(i));
    fprintf('APDD (Avg Delay Data): %.2e +- %.2e ms\n', APDD_mean(i), APDD_term(i));
    fprintf('APDV (Avg Delay VoIP): %.2e +- %.2e ms\n', APDV_mean(i), APDV_term(i));
    fprintf('MPDD (Max Delay Data): %.2e +- %.2e ms\n', MPDD_mean(i), MPDD_term(i));
    fprintf('MPDV (Max Delay VoIP): %.2e +- %.2e ms\n', MPDV_mean(i), MPDV_term(i));
    fprintf('TT   (Throughput): %.2e +- %.2e Mbps\n', TT_mean(i), TT_term(i));
end
