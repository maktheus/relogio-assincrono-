-- ############################################################################
-- @copyright   Miguel Grimm <miguelgrimm@gmail>
--
-- @brief       Função digital de geração de pulso programável.
--
-- @file        dsf_timer.vhd
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
-- 				 +student	   Kevin Guimarães <kevin.guimaraes37@gmail.com> 
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
-- @brief      Eliminar de ruído eletrônico pré-ajustável.
--
-- Esta função digital gera um pulso na saída q quando na entrada trigger
-- ocorre a transição de subida, sendo sensível ao redisparo.
--
-- @param[in]  enable  -  1, habilita todas as operações da função digital e
--                        0, cancela a temporização.
--
--             areset  -  1, limpa a saída q para zero, cancelando a temporização e
--                        0, permanece no modo memória.
--
--             data    -  1, largura do pulso da saída q.
--
--             trigger -  0 => 1, coloca a saída q em 1 e dispara a temporização 
--                                na largura de data pulsos de clock.
--                        caso contrário, permanece em 0 no modo estável.
--
--             pos_neg -  1, trigger ativo no nível 1 e 
--                        0, trigger ativo no nível 0.
--
--             clk     -  sinal de sincronismo, ativo na transição de subida.
--
-- @param[out] q       -  pulso em 1, temporização em curso.
--
--             count   -  LEN_PULSE..0, contagem dos ciclos da temporização.
-- ----------------------------------------------------------------------------
entity dsf_timer is

  port (
  
    -- Controles assíncronos.
    enable   :  in      bit;
    areset   :  in      bit;

    -- Disparo da temporização pré-ajustável: 4 bits.
	data     :  in      integer range (2**4-1) downto 0;
    trigger  :  in      bit;
    pos_neg  :  in      bit;
	
    -- Relógio de sincronismo.
    clk      :  in      bit;
	
    -- Ciclo de trabalho.
    q        :  buffer  bit := '0';
	 
    -- Parâmetro: tempo de 60 pulsos de clk.
	 count    :  buffer  integer range data'high downto 0 := 0
		
  );
  
end dsf_timer;



architecture timer_a of dsf_timer is

  -- --------------------------------------------------------------------------
  -- @detail              CONSTANTES GLOBAIS DA ARQUITETURA                  --
  -- --------------------------------------------------------------------------

  -- Fator de escala do divisor (SCALE FACTOR).
  constant  MAX_COUNT   :  integer  :=  data'high;


  -- --------------------------------------------------------------------------
  -- @detail                FUNÇÕES GLOBAIS DA ARQUITETURA                   --
  -- --------------------------------------------------------------------------

  function reset_count (enable : bit; count : integer) return integer is

    variable  cnt  :  integer range MAX_COUNT downto 0;

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



  function load_count (enable : bit; count, data : integer) return integer is

    variable  cnt  :  integer range MAX_COUNT downto 0;

  begin

    if (enable = '1') then

      -- Modo carga.
      cnt := data;

    else

	  -- Modo memória.
      cnt := count;

    end if;

    return cnt;

  end load_count;



  function dec_count (enable : bit; count : integer)  return integer is

	variable  cnt  :  integer range MAX_COUNT downto 0;

  begin

    if (enable = '1') then
	
      if (count >= 1) then

        -- Modo contagem - Estado instável.
        cnt := count - 1;

      else

        -- Modo limpa - Estado estável.
        cnt := 0;

      end if;

    else

      -- Modo memória.
      cnt := count;

    end if;

    return cnt;

  end dec_count;



  function get_q (areset : bit; count : integer)  return bit is

	variable  q  :  bit;

  begin

    if (areset = '0') and (count >= 1) then

      -- Modo contagem - estado instável.
      q := '1';

    else

      -- Modo limpa - estado estável.
      q := '0';

    end if;

    return q;

  end get_q;

begin
  
  -- OP1. Contagem decrescente.
  count <= reset_count(enable, count) when (areset = '1') else
           load_count(enable, count, data) when (trigger = pos_neg) else
		   dec_count(enable, count) when low2high(clk);

  -- OP2. Pulso de saída.
  q <= get_q(areset, count) when (enable = '1');
  
end timer_a;







