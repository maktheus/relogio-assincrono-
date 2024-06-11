-- ############################################################################
-- @copyright   Miguel Grimm <miguelgrimm@gmail> & 
--
-- @brief       Decodificador estendido Hexadecimal para Display de 7 Seg.
--
-- @file        dsf_hexa2ssd.vhd
-- @version     1.0
-- @date        27 Julho 2020
--
-- @section     HARDWARES & SOFTWARES.
--              +compiler     Quartus Web Edition versão 13 sp 1.
--                            Quartus Primer Lite Edition Versão 18.
--              +revisions    Versão (data): Descrição breve.
--                            ++ 1.0 (27 Julho 2020): Versão inicial.
--
-- @section     AUTHORS & DEVELOPERS.
--              +institution  UFAM - Universidade Federal do Amazonas.
--              +courses      Engenharia da Computação / Engenharia Elétrica.
--              +teacher      Miguel Grimm <miguelgrimm@gmail.com>
--
--                            Compilação e Simulação:
-- 				 +student ++   Kevin Guimarães <kevin.guimaraes37@gmail.com>
--
-- @section     LICENSE
--
--              GNU General Public License (GNU GPL).
--
--              Este programa é um software livre; Você pode redistribuí-lo
--              e/ou modificá-lo de acordo com os termos do "GNU General Public
--              License" como publicado pela Free Software Foundation; Seja a
--              versão 3 da licença, ou qualquer outra versão posterior.
--
--              Este programa é distribuído na esperança de que seja útil,
--              mas SEM QUALQUER GARANTIA; Sem a garantia implícita de
--              COMERCIALIZAÇÃO OU USO PARA UM DETERMINADO PROPÓSITO.
--              Veja o site da "GNU General Public License" para mais detalhes.
--
-- @htmlonly    http://www.gnu.org/copyleft/gpl.html
--
-- @section     REFERENCES.
--              + CHU, Pong P. RTL Hardware Design Using VHDL. 2006. 669 p.
--              + AMORE, Robert d'. VHDL - Descrição e Síntese de Circuitos
--                Digitais. 2. ed. Rio de Janeiro : LTC, 2012. 292 p.
--              + PEDRONI, Volnei A. Eletrônica Digital Moderna e VHDL.
--                Rio de Janeiro : Elsevier, 2010. 619 p.
--              + TOCCI, Ronald J., WIDNER, Neal S. & MOSS, Gregory.
--                Sistemas Digitais - Princípios e Aplicações, 12. ed.
--                São Paulo : Person Education do Brasil, 2018. 1034 p.
--
-- ############################################################################

library ieee;
use ieee.numeric_bit.all;
use work.dsf_std.all;



-- ----------------------------------------------------------------------------
-- @detail     +ESPECIFICAÇÃO DA INTERFACE.
--
-- Esta função digital realiza a decodificação do código Hexadecimal
-- para o código do Display de Sete Segmentos (SSD).
--
-- @param[in]  enable   -  1, habilita a operação da função digital e
--                         0, desabilita a função digital.
--
--             hexa     -  0..15 (decimal), valor em hexadecimal.
--
--             cin      -  1, solicita que ocorra um vai branco se a
--                            entrada data em hexadecimal for igual a zero e
--                         0, em caso contrário.
--
--             pos_neg  -  1, leds do display acendem em 1 (ativação positiva)
--                            na configuração catodo comum e
--                         0, leds do display acendem em 0 (ativação negativa)
--                            na configuração anodo comum.
--
-- @param[out] segments -  00, 7E, 30, 6D, 79, 33, 5B, 5F, 70, 7F, 73, 77,
--                         1F, 4E, 3D, 4F, 47 (hexa) / ativação positiva 
--
--                         7F, 81, CF, 92, 86, CC, A4, A0, 8F, 80, 8C, 88,
--                         E0, B1, C2, B0, B8 (hexa) / ativação negativa,
--                         valor binário dos segmentos a,b,c,d,e,f,g de 7 seg.
--
--             cout     -  1, indica que existe um vai branco ou
--                         0, em caso contrário.
-- ----------------------------------------------------------------------------
entity dsf_hexa2ssd is

  port (

    -- Controle das saídas do transporte de vai branco e resultado.
    enable    :  in      bit;
	
    -- Configuração do tipo de display.
    pos_neg   :  in      integer range 1 downto 0; 

    -- Dado do código hexadecimal no formato decimal.
    hexa      :  in      integer range 15 downto 0;
	
    -- Resultado do código SSD (a,b,c,d,e,f,g)no formato bit.
    segments  :  buffer  bit_vector (6 downto 0);
	
	-- Transporte de branco.
    cin       :  in      bit;
    cout      :  buffer  bit

  );

end dsf_hexa2ssd;


architecture hexa2ssd_a of dsf_hexa2ssd is

  -- ----------------------------------------------------------------------------
  -- Esta função escalar converte do código hexadecimal para o código de 7
  -- segmentos, considerando a ativação dos leds dos segmentos na lógica
  -- positiva (nível lógico alto).
  --
  -- @param[in]  hexa - valor de 0 a 15 (F) do código Hexadecimal.
  --
  -- @return            vetor de bits com os sinais de ativação dos leds,
  --                    sendo os segmentos "abcdef" associados aos conteúdos
  --                    binários dos í­ndices do vetor.
  -- ---------------------------------------------------------------------------- 
  function hexa2ssd (hexa : uint4_t) return bvec7_t is

    -- Valor do código de Display de Sete Segmentos (SSD).
    variable  segments  :  bit_vector (6 downto 0);
  
  begin

    case hexa is
  
      -- Decodificação de número.
	  when 0  => segments := "1111110";  -- 7E h
      when 1  => segments := "0110000";  -- 30 h
      when 2  => segments := "1101101";  -- 6D h
      when 3  => segments := "1111001";  -- 79 h
      when 4  => segments := "0110011";  -- 33 h
      when 5  => segments := "1011011";  -- 5B h
      when 6  => segments := "1011111";  -- 5F h
      when 7  => segments := "1110000";  -- 70 h
      when 8  => segments := "1111111";  -- 7F h
      when 9  => segments := "1110011";  -- 73 h
	
      -- Decodificação de letra minúscula, quando possível.
      when 10 => segments := "1110111";  -- 77 h
      when 11 => segments := "0011111";  -- 1F h
      when 12 => segments := "1001110";  -- 4E h
      when 13 => segments := "0111101";  -- 3D h
      when 14 => segments := "1001111";  -- 4F h
      when 15 => segments := "1000111";  -- 47 h
	
    end case;
  
    return segments;

  end hexa2ssd;
  
  -- ----------------------------------------------------------------------------
  -- @detail     +BUFFERS LOCAIS DA ARQUITETURA.
  -- ----------------------------------------------------------------------------

  -- Buffer de ativação positiva do código do Display de 7 Segmentos (SSD).
  signal  seg_pos   :  bit_vector (6 downto 0);

begin

  -- OP1. Transporte do vai branco.
  cout <= cout_hexa(hexa, cin) when (enable = '1') else
          '0';

  -- OP2. Resultado da decodificação.           
  seg_pos <= hexa2ssd(hexa) when (enable = '1') and (cout = '0') else
             (others => '0');         

  -- OP3. Configuração da ativação positiva/negativa da saída.
  segments <= seg_pos when (pos_neg = 1) else
	          not (seg_pos);

end hexa2ssd_a;