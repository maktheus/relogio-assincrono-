-- ############################################################################
-- @copyright   Miguel Grimm <miguelgrimm@gmail>
--
-- @brief       Função digital de divisão de frequência.
--
-- @file        dsf_freqdivider.vhd
-- @version     1.0
-- @date        27 Julho 2021
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
-- 				 +student	  Kevin Guimarães <kevin.guimaraes37@gmail.com> 
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
-- @brief      Divisor de frequência pré-ajustável.
--
-- Esta função digital realiza a divisão de frequência por LEN_SCALE_FACTOR. A
-- forma de onda da saída duty possui o ciclo de trabalho pré-definido em
-- LEN_DUTY_CYCLE.
--
-- @param[in]  enable  -  1, habilita todas as operações da função digital e
--                        0, desabilita em caso contrário.
--
--             areset  -  1, limpa a contagem do dividor e
--                        0, bebhuma operação.
--
--             clk     -  sinal de sincronismo, ativo na transição de subida.
--
-- @param[out] q       -  1..0, forma de onda com ciclo de trabalho.
--
--             count   -  contagem do divisor de frequência.
-- ----------------------------------------------------------------------------
entity dsf_freqdivider is

  port (
 
    -- Habilitação da função digital.
    enable  :  in       bit;
	areset  :  in       bit;

    -- Frequência de entrada do divisor.
    clk     :  in       bit;

    -- Frequência de saída do divisor.
	q       :  buffer   bit;

	-- Parâmetro: Fator de Escala do divisor: 1000 (SCALE_FACTOR).
	count   :  buffer  integer range (1000 - 1) downto 0 := 0

  );

end dsf_freqdivider;



architecture freqdivider_a of dsf_freqdivider is

  -- --------------------------------------------------------------------------
  -- @detail              CONSTANTES GLOBAIS DA ARQUITETURA                  --
  -- --------------------------------------------------------------------------

  -- Fator de escala do divisor (SCALE FACTOR).
  constant  MAX_FACTOR   :  integer  :=  count'high;
  constant  LEN_FACTOR   :  integer  :=  MAX_FACTOR + 1;
  
  -- Parâmetro: Ciclo de trabalho do divisor (DUTY_CYCLE).
  constant  LEN_DUTY     :  integer  :=  1;  -- 1 ciclo em alto.
  constant  LIM_DUTY     :  integer  :=  LEN_FACTOR - LEN_DUTY;
  
  
  -- --------------------------------------------------------------------------
  -- @detail               FUNÇÕES GLOBAIS DA ARQUITETURA                    --
  -- --------------------------------------------------------------------------

  function reset_count (enable : bit; count : integer) return integer is

	variable  cnt  :  integer range MAX_FACTOR downto 0;

  begin

    if (enable = '1') then

      -- Modo limpa.
      cnt := 0;

    else

      -- Modo memória.
      cnt := count;

    end if;

    return cnt;

  end reset_count;



  function inc_count (enable : bit; count : integer) return integer is

	variable  cnt  :  integer range MAX_FACTOR downto 0;

  begin

    if (enable = '1') then

      -- Modo contagem.
      cnt := increment(count, MAX_FACTOR);

    else

      -- Modo memória.
      cnt := count;

    end if;

    return cnt;

  end inc_count;



  function get_q (areset : bit; count : integer) return bit is

	variable  q  :  bit;

  begin

    if (areset = '1') then

      -- Modo limpa.
      q := '0';

    else

      -- Detecção do ciclo de trabalho.
      if (count < LIM_DUTY) then

        -- Modo baixo.
        q := '0';

      else

        -- Modo alto.
        q := '1';

      end if;

    end if;

    return q;

  end get_q


begin

  -- OP1. Contagem crescente.
  count <= reset_count(enable, count) when (areset = '1') else
           inc_count(enable, count) when low2high(clk);

  -- OP2. Ciclo de trabalho.
  q <= get_q (areset, count);

end freqdivider_a;









