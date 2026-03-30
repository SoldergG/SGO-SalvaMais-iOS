import SwiftUI

// MARK: - Page 1 Content (Frente)

extension ISNReportFormView {
    
    var page1Content: some View {
        VStack(spacing: 16) {
            // 1. CONTEXTO OPERACIONAL
            ISNBox(title: "Contexto Operacional") {
                // Posto
                VStack(alignment: .leading, spacing: 6) {
                    Text(isPool ? "NOME DA PISCINA" : "LOCAL DA OCORRÊNCIA")
                        .font(.system(size: 9, weight: .black))
                        .tracking(2)
                        .foregroundColor(.sgoTextMuted)
                    
                    Picker("Posto", selection: $selectedServicoId) {
                        Text("Escolher Posto...").tag("")
                        ForEach(dashboardVM.activeServicos) { s in
                            Text(s.name).tag(s.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sgoGlassField()
                    .onChange(of: selectedServicoId) { _, newVal in
                        if let s = dashboardVM.activeServicos.first(where: { $0.id == newVal }) {
                            localidade = s.location
                            concelho = s.location
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    ISNTextField(label: "Localidade", text: $localidade)
                    ISNTextField(label: "Concelho", text: $concelho)
                }
                
                HStack(spacing: 12) {
                    ISNTextField(label: "Data", text: $dataStr, placeholder: "AAAA-MM-DD")
                    ISNTextField(label: "Hora", text: $hora, placeholder: "HH:MM")
                }
                
                HStack(spacing: 20) {
                    ISNCheckbox(label: "Em Serviço", isChecked: Binding(
                        get: { emServico },
                        set: { emServico = $0; if $0 { foraServico = false } }
                    ))
                    ISNCheckbox(label: "Fora de Serviço", isChecked: Binding(
                        get: { foraServico },
                        set: { foraServico = $0; if $0 { emServico = false } }
                    ))
                }
            }
            
            // TIPOLOGIA PISCINA (condicional)
            if isPool {
                poolTypologySection
            }
            
            // 2. ID NADADOR-SALVADOR
            ISNBox(title: "Identificação Nadador-Salvador") {
                ISNTextField(label: "Nome Completo", text: $nsNome)
                HStack(spacing: 12) {
                    ISNTextField(label: "Nacionalidade", text: $nsNacionalidade)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SEXO").font(.system(size: 9, weight: .black)).tracking(2).foregroundColor(.sgoTextMuted)
                        HStack(spacing: 16) {
                            ISNCheckbox(label: "M", isChecked: Binding(get: { nsSexoM }, set: { nsSexoM = $0; if $0 { nsSexoF = false } }))
                            ISNCheckbox(label: "F", isChecked: Binding(get: { nsSexoF }, set: { nsSexoF = $0; if $0 { nsSexoM = false } }))
                        }
                    }
                }
                HStack(spacing: 12) {
                    ISNTextField(label: "Contacto", text: $nsContacto)
                    ISNTextField(label: "N.º NS", text: $nsNumero)
                }
                SignatureCanvasView(title: "Assinatura Nadador-Salvador", signatureImage: $sigAgent)
            }
            
            // 3. ID VÍTIMA
            ISNBox(title: "Identificação da Vítima") {
                ISNTextField(label: "Nome Completo", text: $vitimaNome)
                ISNTextField(label: "Morada (Rua)", text: $vitimaMorada)
                HStack(spacing: 8) {
                    ISNTextField(label: "N.º Porta", text: $vitimaPorta)
                    ISNTextField(label: "Andar", text: $vitimaAndar)
                    ISNTextField(label: "Cód. Postal", text: $vitimaCP)
                }
                HStack(spacing: 12) {
                    ISNTextField(label: "Localidade", text: $vitimaLocalidade)
                    ISNTextField(label: "Nacionalidade", text: $vitimaNacionalidade)
                }
                HStack(spacing: 12) {
                    ISNTextField(label: "Idade", text: $vitimaIdade)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SEXO").font(.system(size: 9, weight: .black)).tracking(2).foregroundColor(.sgoTextMuted)
                        HStack(spacing: 16) {
                            ISNCheckbox(label: "M", isChecked: Binding(get: { vitimaSexoM }, set: { vitimaSexoM = $0; if $0 { vitimaSexoF = false } }))
                            ISNCheckbox(label: "F", isChecked: Binding(get: { vitimaSexoF }, set: { vitimaSexoF = $0; if $0 { vitimaSexoM = false } }))
                        }
                    }
                }
                ISNTextField(label: "Contacto", text: $vitimaContacto)
            }
            
            // 4. INCIDENTE E CONSEQUÊNCIA
            incidentSection
            
            // 5. ATIVIDADE E INTERVENÇÃO
            activitySection
            
            // 6. RECUSA DE TRATAMENTO
            ISNBox(title: "Recusa de Tratamento*") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        Text("Eu, ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        TextField("Nome completo", text: $recusaEu)
                            .font(.system(size: 11, weight: .black))
                            .frame(maxWidth: 160)
                            .overlay(Rectangle().fill(Color.sgoRed.opacity(0.3)).frame(height: 1), alignment: .bottom)
                        Text(", com BI/CC n.º ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        TextField("Documento", text: $recusaCC)
                            .font(.system(size: 11, weight: .black))
                            .frame(maxWidth: 120)
                            .overlay(Rectangle().fill(Color.sgoRed.opacity(0.3)).frame(height: 1), alignment: .bottom)
                    }
                    Text(", declaro que, após ter tomado conhecimento dos riscos decorrentes da minha decisão, recuso receber tratamento e ser transportado até à unidade de saúde.")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                SignatureCanvasView(title: "Assinatura de Recusa", signatureImage: $sigRecusal)
                
                Text("* No caso de menores de 18 anos, ou adultos legalmente \"incapazes\" de tomar essa decisão, o tratamento deve ser sempre prestado.")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.sgoRed.opacity(0.7))
                    .italic()
            }
            
            // 7. OBSERVAÇÕES P1
            ISNBox(title: "Observações Adicionais") {
                TextEditor(text: $obsAdicionaisP1)
                    .font(.system(size: 13, weight: .bold))
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemGray6).opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                                    .foregroundColor(Color.gray.opacity(0.15))
                            )
                    )
                    .scrollContentBackground(.hidden)
            }
            
            // Botão próxima página
            Button {
                withAnimation(.spring(response: 0.3)) { page = 2 }
            } label: {
                Text("Próxima Página (Verso) →")
                    .frame(maxWidth: .infinity)
                    .sgoGlassButton(isDestructive: false)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }
    
    // MARK: - Pool Typology
    
    private var poolTypologySection: some View {
        ISNBox(title: "Tipologia da Piscina") {
            VStack(alignment: .leading, spacing: 12) {
                Text("MUNICIPAL:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                ISNCheckbox(label: "Coberta", isChecked: $tipoMunCob)
                ISNCheckbox(label: "Descoberta", isChecked: $tipoMunDes)
                ISNCheckbox(label: "Natural", isChecked: $tipoMunNat)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("UNID. HOTELEIRA:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                ISNCheckbox(label: "Coberta", isChecked: $tipoHotCob)
                ISNCheckbox(label: "Descoberta", isChecked: $tipoHotDes)
                ISNCheckbox(label: "Parque Aquático", isChecked: $tipoHotAq)
            }
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("DESPORTIVO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Coberta", isChecked: $tipoDespCob)
                    ISNCheckbox(label: "Descoberta", isChecked: $tipoDespDes)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("PRIVADO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Coberta", isChecked: $tipoPrivCob)
                    ISNCheckbox(label: "Descoberta", isChecked: $tipoPrivDes)
                }
            }
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("CAMPISMO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Coberta", isChecked: $tipoCampCob)
                    ISNCheckbox(label: "Descoberta", isChecked: $tipoCampDes)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("ESCOLA:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Coberta", isChecked: $tipoEscCob)
                    ISNCheckbox(label: "Descoberta", isChecked: $tipoEscDes)
                }
            }
            ISNTextField(label: "Outra", text: $tipoOutraStr)
        }
    }
    
    // MARK: - Incident Section
    
    private var incidentSection: some View {
        ISNBox(title: "Incidente e Consequência") {
            // Tipo de Incidente
            ISNGroupTitle(title: "Tipo de Incidente")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "Salvamento", isChecked: $tipoSalvamento)
                ISNCheckbox(label: "1ºs Socorros", isChecked: $tipo1Socorros)
                ISNCheckbox(label: "Busca", isChecked: $tipoBusca)
            }
            ISNTextField(label: "Outro", text: $tipoOutro)
            
            // Consequência
            ISNGroupTitle(title: "Consequência")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "Ileso", isChecked: $consIleso)
                ISNCheckbox(label: "Ferido", isChecked: $consFerido)
                ISNCheckbox(label: "Morto", isChecked: $consMorto)
                ISNCheckbox(label: "Desaparecido", isChecked: $consDesaparecido)
            }
            ISNTextField(label: "Outro", text: $consOutro)
            
            // Causas
            ISNGroupTitle(title: "Causas Prováveis do Acidente")
            if isPool {
                poolCausesView
            } else {
                beachCausesView
            }
        }
    }
    
    private var beachCausesView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ISNCheckbox(label: "Correntes", isChecked: $causaCorrentes)
            ISNCheckbox(label: "Lesão Traumática", isChecked: $causaTraumatica)
            ISNCheckbox(label: "Nadar Mal", isChecked: $causaNadarMal)
            ISNCheckbox(label: "Picadas", isChecked: $causaPicadas)
            ISNCheckbox(label: "Cansaço / Exaustão", isChecked: $causaCansaco)
            ISNCheckbox(label: "Reação Alérgica", isChecked: $causaAlergica)
            ISNCheckbox(label: "Dor Precordial", isChecked: $causaDorPrecordial)
            ISNCheckbox(label: "Insolação", isChecked: $causaInsolacao)
            ISNCheckbox(label: "Falha de Equipamento", isChecked: $causaFalhaEquip)
            ISNCheckbox(label: "Criança Perdida", isChecked: $causaPerdida)
            ISNCheckbox(label: "Afogamento", isChecked: $causaAfogamento)
            ISNCheckbox(label: "Cãibra", isChecked: $causaCaibra)
        }
    }
    
    private var poolCausesView: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "AVC", isChecked: $causaAVC)
                ISNCheckbox(label: "Angina de Peito", isChecked: $causaAngina)
                ISNCheckbox(label: "Enfarte", isChecked: $causaEnfarte)
                ISNCheckbox(label: "Choque", isChecked: $causaChoque)
                ISNCheckbox(label: "Hemorragia", isChecked: $causaHemorragia)
                ISNCheckbox(label: "Paragem Digestiva", isChecked: $causaParagemDigestiva)
                ISNCheckbox(label: "Queimadura", isChecked: $causaQueimadura)
                ISNCheckbox(label: "Insolação", isChecked: $causaInsolacao)
                ISNCheckbox(label: "Golpe de Calor", isChecked: $causaGolpeCalor)
                ISNCheckbox(label: "Cefaleias", isChecked: $causaCefaleias)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("TRAUMATISMO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ISNCheckbox(label: "Vertebromedular", isChecked: $traumaVertebro)
                    ISNCheckbox(label: "Cranioencefálico", isChecked: $traumaCranio)
                    ISNCheckbox(label: "Músculo-esquelético", isChecked: $traumaMusculo)
                    ISNCheckbox(label: "Queda", isChecked: $traumaQueda)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6).opacity(0.3)))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "Crise Diabética", isChecked: $causaDiabetica)
                ISNCheckbox(label: "Crise Epilética", isChecked: $causaEpileptica)
                ISNCheckbox(label: "Picada de Insecto", isChecked: $causaPicada)
                ISNCheckbox(label: "Feridas / Escoriações", isChecked: $causaFeridas)
                ISNCheckbox(label: "Afogamento", isChecked: $causaAfogamento)
            }
            ISNTextField(label: "Outra", text: $causaOutra)
        }
    }
    
    // MARK: - Activity Section
    
    private var activitySection: some View {
        ISNBox(title: "Atividade e Intervenção") {
            ISNGroupTitle(title: "Atividade no Momento do Acidente")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "Natação", isChecked: $ativNatacao)
                ISNCheckbox(label: "Aula de Grupo", isChecked: $ativAula)
                ISNCheckbox(label: "Salto para a Água", isChecked: $ativSalto)
                ISNCheckbox(label: "Atividade Lúdica", isChecked: $ativLudica)
                ISNCheckbox(label: "Apneia", isChecked: $ativApneia)
                ISNCheckbox(label: "Caminhada / Corria", isChecked: $ativCaminhada)
                ISNCheckbox(label: "Flutuar / Boiar", isChecked: $ativFlutuar)
                ISNCheckbox(label: "Ativ. de Mergulho", isChecked: $ativMergulho)
            }
            ISNTextField(label: "Outra", text: $ativOutra)
            
            // Condições Ambientais (só praias)
            if !isPool {
                environmentalConditionsView
            }
            
            // Entidades
            ISNGroupTitle(title: "Entidades que Prestaram Assistência")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "INEM", isChecked: $entInem)
                ISNCheckbox(label: "Bombeiros", isChecked: $entBombeiros)
                ISNCheckbox(label: "Polícia Marítima", isChecked: $entPM)
                ISNCheckbox(label: "GNR", isChecked: $entGNR)
                ISNCheckbox(label: "PSP", isChecked: $entPSP)
                ISNCheckbox(label: "Nadador-Salvador", isChecked: $entNS)
                if !isPool {
                    ISNCheckbox(label: "Viatura Amarok", isChecked: $entAmarok)
                    ISNCheckbox(label: "Estação Salva-Vidas", isChecked: $entESV)
                }
            }
            ISNTextField(label: "Particular", text: $entParticular)
            
            // Meios
            ISNGroupTitle(title: "Meio(s) Envolvido(s)")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "Nenhum Equipamento", isChecked: $meioNenhum)
                ISNCheckbox(label: "Cinto Salvamento", isChecked: $meioCinto)
                ISNCheckbox(label: "Boia Circular", isChecked: $meioBoiaCircular)
                if isPool {
                    ISNCheckbox(label: "Vara de Salvamento", isChecked: $meioVara)
                    ISNCheckbox(label: "Plano Rígido", isChecked: $meioPlanoRigido)
                } else {
                    ISNCheckbox(label: "Embarcação", isChecked: $meioEmbarcacao)
                    ISNCheckbox(label: "Mota de Água", isChecked: $meioMotaAgua)
                    ISNCheckbox(label: "Boia Torpedo", isChecked: $meioBoiaTorpedo)
                    ISNCheckbox(label: "Moto 4x4", isChecked: $meioMoto4x4)
                    ISNCheckbox(label: "Viatura 4x4", isChecked: $meioViatura4x4)
                    ISNCheckbox(label: "Prancha", isChecked: $meioPrancha)
                    ISNCheckbox(label: "GOES", isChecked: $meioGoes)
                }
            }
            ISNTextField(label: "Outro", text: $meioOutro)
            
            // Evacuação
            ISNGroupTitle(title: "Evacuação")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ISNCheckbox(label: "INEM", isChecked: $evacInem)
                ISNCheckbox(label: "Bombeiros", isChecked: $evacBombeiros)
                ISNCheckbox(label: "Viatura Particular", isChecked: $evacViatPart)
                ISNCheckbox(label: "Não foi Necessária", isChecked: $evacNaoNec)
                if !isPool {
                    ISNCheckbox(label: "Embarc. Capitania", isChecked: $evacEmbCap)
                    ISNCheckbox(label: "Viatura Capitania", isChecked: $evacViatCap)
                    ISNCheckbox(label: "Helicóptero FAP", isChecked: $evacHeliFAP)
                    ISNCheckbox(label: "Helicóptero CNBCP", isChecked: $evacHeliCNBCP)
                }
            }
            ISNTextField(label: "Outro", text: $evacOutro)
        }
    }
    
    // MARK: - Environmental Conditions (Beach only)
    
    private var environmentalConditionsView: some View {
        VStack(spacing: 14) {
            ISNGroupTitle(title: "Condições Ambientais")
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("VENTO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Fraco", isChecked: $condVentoFraco)
                    ISNCheckbox(label: "Moderado", isChecked: $condVentoMod)
                    ISNCheckbox(label: "Forte", isChecked: $condVentoForte)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("VISIBILIDADE:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Má", isChecked: $condVisibMa)
                    ISNCheckbox(label: "Média", isChecked: $condVisibMedia)
                    ISNCheckbox(label: "Boa", isChecked: $condVisibBoa)
                }
            }
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CORRENTE:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Forte", isChecked: $condCorrenteForte)
                    ISNCheckbox(label: "Média", isChecked: $condCorrenteMedia)
                    ISNCheckbox(label: "Fraca", isChecked: $condCorrenteFraca)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("MARÉ:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Enchente", isChecked: $condMareEnch)
                    ISNCheckbox(label: "Vazante", isChecked: $condMareVaz)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("ONDULAÇÃO:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                HStack(spacing: 12) {
                    ISNCheckbox(label: "Até 1m", isChecked: $condOndulacao1m)
                    ISNCheckbox(label: "1-2m", isChecked: $condOndulacao1a2m)
                }
                HStack(spacing: 12) {
                    ISNCheckbox(label: "2-3m", isChecked: $condOndulacao2a3m)
                    ISNTextField(label: "Outro", text: $condOndulacaoOutro)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("BANDEIRA:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ISNCheckbox(label: "Verde", isChecked: $condBandVerde)
                    ISNCheckbox(label: "Amarela", isChecked: $condBandAmarela)
                    ISNCheckbox(label: "Vermelha", isChecked: $condBandVerm)
                    ISNCheckbox(label: "Sem Bandeira", isChecked: $condBandSem)
                }
            }
        }
    }
}
