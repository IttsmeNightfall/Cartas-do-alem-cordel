# CardDatabase.gd
# Não coloque "extends ..." aqui

# Enum para facilitar a leitura dos índices do array
enum { ATTACK, HEALTH, TYPE }

const CARDS = {
	# --- CARTAS COMUNS ---
	"Cachaceiro": [2, 4, "Comum"],
	"Briguento": [2, 1, "Comum"],
	"Zeca-Peito-de-Ferro": [1, 7, "Comum"],
	"Velho do Saco": [2, 4, "Comum"],

	# --- CARTAS SERTANEJAS ---
	"O Sanfoneiro": [0, 6, "Sertanejo"],
	"Terezinha": [2, 5, "Sertanejo"],
	"Coronel Bezerra": [3, 6, "Sertanejo"],
	"Vaqueiro Jacó": [7, 7, "Sertanejo"],
	"Cabra da Peste": [3, 6, "Sertanejo"],

	# --- CARTAS DE BICHO ---
	"Matilha": [1, 2, "Bicho"],
	"Boto-Cor-de-Rosa": [2, 5, "Bicho"],
	"Besta Fera": [10, 10, "Bicho"], # Custo alto/Sacrifício deve ser tratado na lógica do jogo
	"Chupa Cabra": [6, 6, "Bicho"],
	"Curupira": [4, 4, "Bicho"],
	"Encourado": [4, 6, "Bicho"],

	# --- CARTAS MALASSOMBRADAS ---
	"Mula sem Cabeça": [2, 5, "Malassombrado"], # Ataque duplo deve ser tratado na lógica
	"Corpo-Seco": [4, 1, "Malassombrado"],
	"Matinta-Perera": [3, 3, "Malassombrado"],
	"Cumade-Fulozinha": [1, 4, "Malassombrado"],
	"Maçone": [4, 7, "Malassombrado"],

	# --- CARTAS CANGACEIROS ---
	"O Diabo Loiro": [8, 6, "Cangaceiro"],
	"Balão": [2, 4, "Cangaceiro"],
	"Zé Baiano": [3, 3, "Cangaceiro"],
	"Sinhô Pereira": [3, 5, "Cangaceiro"],
	"Jesuíno Brilhante": [2, 7, "Cangaceiro"],
}