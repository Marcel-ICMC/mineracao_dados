-Marcel Otoboni de Lima
--QUESTAO 1
--SE TABELA DE PACIENTES SO CONTEM DISTINTOS
--NUMERO DE PACIENTES, R: 332117
SELECT COUNT(*) FROM PACIENTE;

--NUMERO DE PACIENTES HOMENS, R: 152251
SELECT COUNT(*) FROM PACIENTE 
    WHERE PACIENTE.IC_SEXO = 'M' OR PACIENTE.IC_SEXO = 'm';

--NUMERO DE PACIENTES HOMENS, R: 179864
SELECT COUNT(*) FROM PACIENTE 
    WHERE PACIENTE.IC_SEXO = 'F' OR PACIENTE.IC_SEXO = 'f';

--TEMOS DUAS LINHAS COM SEXO IGUAL A NULL, R: 2
SELECT COUNT(*) FROM PACIENTE WHERE PACIENTE.IC_SEXO IS NULL;


--questao 2
-- distribuicao em cada genero por decada de vida
SELECT COUNT(*),  FLOOR((date_part('year', CURRENT_DATE)-P.AA_NASCIMENTO::INTEGER)/10) || '0s' as DECADA,P.IC_SEXO
FROM PACIENTE P
WHERE P.AA_NASCIMENTO SIMILAR TO '___(0|1|2|3|4|5|6|7|8|9)'
GROUP BY DECADA, P.IC_SEXO;

--SEPARANDO POR FAIXA ETARIA
SELECT COUNT(*),  FLOOR((date_part('year', CURRENT_DATE)-P.AA_NASCIMENTO::INTEGER)/10) || '0s' as DECADA
FROM PACIENTE P
WHERE P.AA_NASCIMENTO SIMILAR TO '___(0|1|2|3|4|5|6|7|8|9)'
GROUP BY DECADA;

--SELECIONANDO PACIENTES POR DECADA
SELECT COUNT(*),  FLOOR(P.AA_NASCIMENTO::INTEGER/10) || '0S' as DECADA
FROM PACIENTE P
WHERE P.AA_NASCIMENTO SIMILAR TO '___(0|1|2|3|4|5|6|7|8|9)'
GROUP BY DECADA;


--QUESTAO 3 R:10271(???)
SELECT MAX(T.C) FROM
(SELECT COUNT(*) AS C, P.ID_PACIENTE
FROM PACIENTE P INNER JOIN EXAMES E ON P.ID_PACIENTE = E.ID_PACIENTE
GROUP BY P.ID_PACIENTE) T;


--QUESTAO 4 MULHERES R: 30.6
--HOMENS 29
SELECT AVG(T.C) FROM
(SELECT COUNT(*) AS C, P.IC_SEXO,P.ID_PACIENTE
FROM PACIENTE P INNER JOIN EXAMES E ON P.ID_PACIENTE = E.ID_PACIENTE
WHERE P.IC_SEXO = 'F' OR P.IC_SEXO = 'f'
GROUP BY P.ID_PACIENTE) AS T;

SELECT AVG(T.C) FROM
(SELECT COUNT(*) AS C, P.IC_SEXO,P.ID_PACIENTE
FROM PACIENTE P INNER JOIN EXAMES E ON P.ID_PACIENTE = E.ID_PACIENTE
WHERE P.IC_SEXO = 'M' OR P.IC_SEXO = 'm'
GROUP BY P.ID_PACIENTE) AS T;


--QUESTAO 5
--19384 casos confirmados de 191064 dos exames 'NOVO CORONAVÍRUS 2019 (SARS-CoV-2), DETECÇÃO POR PCR'
SELECT COUNT(*), E.DE_RESULTADO
FROM EXAMES E
WHERE E.DE_EXAME = 'NOVO CORONAVÍRUS 2019 (SARS-CoV-2), DETECÇÃO POR PCR'
GROUP BY E.DE_RESULTADO;

--AGORA COM RELACAO A TODOS OS EXAMES RELACIONADOS A COVID
--NUMERO DE EXAMES SOLICITADOS RELACIONADOS A COVID. R: 1150520
SELECT COUNT(*), E.DE_EXAME
FROM EXAMES E
WHERE UPPER(E.DE_EXAME) LIKE '%COVID%'
OR UPPER(E.DE_EXAME) LIKE '%SARS-COV-2%'
GROUP BY E.DE_EXAME;

-- EXAMES QUE DERAM POSITIVO R:109262
SELECT COUNT(*)
FROM EXAMES E
WHERE (UPPER(E.DE_EXAME) LIKE '%COVID%'
OR UPPER(E.DE_EXAME) LIKE '%SARS-COV-2%'
OR UPPER(E.DE_EXAME) LIKE '%COV%')
AND ((E.DE_VALOR_REFERENCIA NOT SIMILAR TO '%(0|1|2|3|4|5|6|7|8|9)'
AND UPPER(E.DE_VALOR_REFERENCIA) != 'NAO DISPONIVEL'
AND UPPER(E.DE_RESULTADO) NOT LIKE (UPPER(E.DE_VALOR_REFERENCIA)||'%')
AND UPPER(RTRIM(E.DE_RESULTADO)) NOT IN ('INDETERMINADO','INCONCLUSIVO', 'INDETECTÁVEL'))
OR (E.DE_VALOR_REFERENCIA SIMILAR TO '%(0|1|2|3|4|5|6|7|8|9)'
AND E.DE_RESULTADO SIMILAR TO '%(0|1|2|3|4|5|6|7|8|9)'
AND TRANSLATE(SUBSTRING(E.DE_RESULTADO FROM LENGTH(E.DE_RESULTADO) - 2 FOR 3),',','.')::FLOAT
        >TRANSLATE(SUBSTRING(E.DE_VALOR_REFERENCIA FROM LENGTH(E.DE_VALOR_REFERENCIA) - 2 FOR 3),',','.')::FLOAT));


--QUESTAO 6
--a coluna exames.de_resultado tem muitos valores diferentes para um mesmo significado
--isso precisara de tratamento
SELECT COUNT(*), E.DE_RESULTADO, date_part('year', CURRENT_DATE)-P.AA_NASCIMENTO::INTEGER as IDADE
FROM PACIENTE P INNER JOIN EXAMES E ON P.ID_PACIENTE = E.ID_PACIENTE
WHERE E.DE_EXAME = 'NOVO CORONAVÍRUS 2019 (SARS-CoV-2), DETECÇÃO POR PCR'
AND P.AA_NASCIMENTO SIMILAR TO '___(0|1|2|3|4|5|6|7|8|9)'
GROUP BY IDADE,E.DE_RESULTADO;


--QUESTAO 7
--SO HA 16957 DESFECHOS REGRISTADOS
--11087 ESTAO REGISTRADOS COMO "ALTA ADMNISTRATIVA"
--5063 ESTAO REGISTRADOS COMO "ALTA MEDICA MELHORADO"
--OBTOS SOMAM SOMENTE 45(??)
--365 DESFECHOS ESTAO NULL
SELECT COUNT(*), D.DE_DESFECHO
FROM DESFECHO D
GROUP BY D.DE_DESFECHO;

--PARA ESPECIFICAMENTE OS EXAMES DE COVID 'NOVO CORONAVÍRUS 2019 (SARS-CoV-2), DETECÇÃO POR PCR'
COUNT(*) DEU ZERO, MUITO ESTRANHO
SELECT COUNT(*)
FROM E
XAMES E INNER JOIN DESFECHO D ON E.ID_ATENDIMENTO = D.ID_ATENDIMENTO
WHERE E.DE_EXAME = 'NOVO CORONAVÍRUS 2019 (SARS-CoV-2), DETECÇÃO POR PCR';

--BUSCANDO PALAVAS NO GERAL DE COVID TEMOS:9206 DESFECHOS
SELECT COUNT(*)
FROM EXAMES E INNER JOIN DESFECHO D ON E.ID_ATENDIMENTO = D.ID_ATENDIMENTO
WHERE UPPER(E.DE_EXAME) LIKE '%COVID%'
OR UPPER(E.DE_EXAME) LIKE '%SARS-COV-2%';

--TEMOS COMO GRANDE MAIORIA (5947) DE 'ALTA ADMINISTRATIVA'
--OBTOS REGISTRADOS SOMAM 86
--258 NULL's
SELECT COUNT(*), D.DE_DESFECHO
FROM EXAMES E INNER JOIN DESFECHO D ON E.ID_ATENDIMENTO = D.ID_ATENDIMENTO
WHERE UPPER(E.DE_EXAME) LIKE '%COVID%'
OR UPPER(E.DE_EXAME) LIKE '%SARS-COV-2%'
GROUP BY D.DE_DESFECHO;