import SwiftUI

// MARK: - Page 2 Content (Verso) + Submit Logic

extension ISNReportFormView {
    
    var page2Content: some View {
        VStack(spacing: 16) {
            // 1. IDENTIFICAÇÃO DE TESTEMUNHAS
            ISNBox(title: "Identificação de Testemunhas") {
                // Testemunha 1
                VStack(spacing: 12) {
                    HStack {
                        Text("TESTEMUNHA 1")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoRed)
                        Spacer()
                    }
                    
                    ISNTextField(label: "Nome", text: $t1Nome)
                    ISNTextField(label: "Morada", text: $t1Morada)
                    ISNTextField(label: "Código Postal", text: $t1CP)
                    HStack(spacing: 12) {
                        ISNTextField(label: "Idade", text: $t1Idade)
                        ISNTextField(label: "N.º Telef.", text: $t1Tel)
                    }
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SEXO").font(.system(size: 9, weight: .black)).tracking(2).foregroundColor(.sgoTextMuted)
                            HStack(spacing: 16) {
                                ISNCheckbox(label: "M", isChecked: Binding(get: { t1SexoM }, set: { t1SexoM = $0; if $0 { t1SexoF = false } }))
                                ISNCheckbox(label: "F", isChecked: Binding(get: { t1SexoF }, set: { t1SexoF = $0; if $0 { t1SexoM = false } }))
                            }
                        }
                        ISNTextField(label: "Nacionalidade", text: $t1Nac)
                    }
                    SignatureCanvasView(title: "Assinatura Testemunha 1", signatureImage: $sigT1)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.systemGray6).opacity(0.3)))
                
                // Testemunha 2
                VStack(spacing: 12) {
                    HStack {
                        Text("TESTEMUNHA 2")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoRed)
                        Spacer()
                    }
                    
                    ISNTextField(label: "Nome", text: $t2Nome)
                    ISNTextField(label: "Morada", text: $t2Morada)
                    ISNTextField(label: "Código Postal", text: $t2CP)
                    HStack(spacing: 12) {
                        ISNTextField(label: "Idade", text: $t2Idade)
                        ISNTextField(label: "N.º Telef.", text: $t2Tel)
                    }
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SEXO").font(.system(size: 9, weight: .black)).tracking(2).foregroundColor(.sgoTextMuted)
                            HStack(spacing: 16) {
                                ISNCheckbox(label: "M", isChecked: Binding(get: { t2SexoM }, set: { t2SexoM = $0; if $0 { t2SexoF = false } }))
                                ISNCheckbox(label: "F", isChecked: Binding(get: { t2SexoF }, set: { t2SexoF = $0; if $0 { t2SexoM = false } }))
                            }
                        }
                        ISNTextField(label: "Nacionalidade", text: $t2Nac)
                    }
                    SignatureCanvasView(title: "Assinatura Testemunha 2", signatureImage: $sigT2)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.systemGray6).opacity(0.3)))
            }
            
            // 2. OBSERVAÇÕES ADICIONAIS P2
            ISNBox(title: "Observações Adicionais") {
                TextEditor(text: $obsAdicionaisP2)
                    .font(.system(size: 13, weight: .bold))
                    .frame(minHeight: 100)
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
            
            // 3. INFORMAÇÃO AOS FAMILIARES
            ISNBox(title: "Informação aos Familiares") {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PESSOALMENTE:")
                            .font(.system(size: 9, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoTextMuted)
                        HStack(spacing: 12) {
                            ISNCheckbox(label: "Sim", isChecked: $infFamPessSim)
                            ISNCheckbox(label: "Não", isChecked: $infFamPessNao)
                        }
                        HStack(spacing: 6) {
                            Text("Outro:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                            TextField("", text: $infFamPessOutro)
                                .font(.system(size: 12, weight: .bold))
                                .overlay(Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1), alignment: .bottom)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TELEFONICAMENTE:")
                            .font(.system(size: 9, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoTextMuted)
                        HStack(spacing: 12) {
                            ISNCheckbox(label: "Sim", isChecked: $infFamTelSim)
                            ISNCheckbox(label: "Não", isChecked: $infFamTelNao)
                        }
                        HStack(spacing: 6) {
                            Text("Outro:").font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted)
                            TextField("", text: $infFamTelOutro)
                                .font(.system(size: 12, weight: .bold))
                                .overlay(Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1), alignment: .bottom)
                        }
                    }
                }
            }
            
            // 4. COMUNICAÇÃO SOCIAL
            ISNBox(title: "Comunicação Social") {
                HStack(spacing: 20) {
                    Text("INFORMADA:")
                        .font(.system(size: 9, weight: .black))
                        .tracking(2)
                        .foregroundColor(.sgoTextMuted)
                    ISNCheckbox(label: "Sim", isChecked: $csInformadaSim)
                    ISNCheckbox(label: "Não", isChecked: $csInformadaNao)
                }
            }
            
            // 5. RELATÓRIO AUTORIDADE COMPETENTE
            ISNBox(title: "Relatório da Autoridade Competente") {
                TextEditor(text: $relatorioAutoridade)
                    .font(.system(size: 13, weight: .bold))
                    .frame(minHeight: 150)
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
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("O RESPONSÁVEL")
                        .font(.system(size: 9, weight: .black))
                        .tracking(3)
                        .foregroundColor(.sgoTextMuted)
                        .italic()
                    SignatureCanvasView(title: "Assinatura do Responsável", signatureImage: $sigResponsible)
                }
            }
            
            // Navigation + Submit
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3)) { page = 1 }
                } label: {
                    Text("← Anterior")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 11, weight: .black))
                        .textCase(.uppercase)
                        .tracking(2)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Color(UIColor.systemGray5)))
                        .foregroundColor(.sgoTextMuted)
                }
                
                Button {
                    Task { await submitISNReport() }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Text("Formalizar Relatório")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sgoGlassButton(isDestructive: true)
                }
                .disabled(selectedServicoId.isEmpty || sigAgent == nil || isSaving)
                .opacity(selectedServicoId.isEmpty || sigAgent == nil ? 0.5 : 1)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }
    
    // MARK: - Success Overlay
    
    var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.sgoGreen)
                
                Text("Relatório ISN Submetido")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white)
                
                Text("PROCESSADO COM SUCESSO")
                    .font(.system(size: 9, weight: .black))
                    .tracking(4)
                    .foregroundColor(.sgoGreen)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // MARK: - Submit
    
    func submitISNReport() async {
        guard let user = authVM.user else { return }
        isSaving = true
        
        let servicoName = dashboardVM.activeServicos.first { $0.id == selectedServicoId }?.name ?? ""
        
        var formData: [String: Any] = [
            "localOcorrencia": servicoName,
            "localidade": localidade,
            "concelho": concelho,
            "data": dataStr,
            "hora": hora,
            "emServico": emServico,
            "foraServico": foraServico,
            // NS
            "nsNome": nsNome, "nsNacionalidade": nsNacionalidade,
            "nsSexoM": nsSexoM, "nsSexoF": nsSexoF,
            "nsContacto": nsContacto, "nsNumero": nsNumero,
            "signatureAgent": sigAgent?.base64String ?? "",
            // Vítima
            "vitimaNome": vitimaNome, "vitimaMorada": vitimaMorada,
            "vitimaPorta": vitimaPorta, "vitimaAndar": vitimaAndar,
            "vitimaCP": vitimaCP, "vitimaLocalidade": vitimaLocalidade,
            "vitimaNacionalidade": vitimaNacionalidade,
            "vitimaIdade": vitimaIdade, "vitimaSexoM": vitimaSexoM, "vitimaSexoF": vitimaSexoF,
            "vitimaContacto": vitimaContacto,
            // Incidente
            "tipoSalvamento": tipoSalvamento, "tipo1Socorros": tipo1Socorros,
            "tipoBusca": tipoBusca, "tipoOutro": tipoOutro,
            "consIleso": consIleso, "consFerido": consFerido,
            "consMorto": consMorto, "consDesaparecido": consDesaparecido, "consOutro": consOutro,
            // Causas
            "causaCorrentes": causaCorrentes, "causaTraumatica": causaTraumatica,
            "causaNadarMal": causaNadarMal, "causaPicadas": causaPicadas,
            "causaCansaco": causaCansaco, "causaAlergica": causaAlergica,
            "causaDorPrecordial": causaDorPrecordial, "causaInsolacao": causaInsolacao,
            "causaFalhaEquip": causaFalhaEquip, "causaPerdida": causaPerdida,
            "causaAfogamento": causaAfogamento, "causaCaibra": causaCaibra,
            // Atividade
            "ativNatacao": ativNatacao, "ativAula": ativAula,
            "ativSalto": ativSalto, "ativLudica": ativLudica,
            "ativApneia": ativApneia, "ativCaminhada": ativCaminhada,
            "ativFlutuar": ativFlutuar, "ativMergulho": ativMergulho, "ativOutra": ativOutra,
            // Entidades
            "entInem": entInem, "entBombeiros": entBombeiros,
            "entPM": entPM, "entGNR": entGNR, "entPSP": entPSP, "entNS": entNS,
            "entAmarok": entAmarok, "entESV": entESV, "entParticular": entParticular,
            // Meios
            "meioNenhum": meioNenhum, "meioCinto": meioCinto,
            "meioBoiaCircular": meioBoiaCircular, "meioOutro": meioOutro,
            // Evacuação
            "evacInem": evacInem, "evacBombeiros": evacBombeiros,
            "evacViatPart": evacViatPart, "evacNaoNec": evacNaoNec, "evacOutro": evacOutro,
            // Recusa
            "recusaEu": recusaEu, "recusaCC": recusaCC,
            "signatureRefusal": sigRecusal?.base64String ?? "",
            "obsAdicionaisP1": obsAdicionaisP1,
            // Testemunhas
            "t1Nome": t1Nome, "t1Morada": t1Morada, "t1CP": t1CP,
            "t1Idade": t1Idade, "t1Tel": t1Tel, "t1SexoM": t1SexoM, "t1SexoF": t1SexoF,
            "t1Nac": t1Nac, "signatureT1": sigT1?.base64String ?? "",
            "t2Nome": t2Nome, "t2Morada": t2Morada, "t2CP": t2CP,
            "t2Idade": t2Idade, "t2Tel": t2Tel, "t2SexoM": t2SexoM, "t2SexoF": t2SexoF,
            "t2Nac": t2Nac, "signatureT2": sigT2?.base64String ?? "",
            "obsAdicionaisP2": obsAdicionaisP2,
            // Familiares
            "infFamPessSim": infFamPessSim, "infFamPessNao": infFamPessNao,
            "infFamPessOutro": infFamPessOutro,
            "infFamTelSim": infFamTelSim, "infFamTelNao": infFamTelNao,
            "infFamTelOutro": infFamTelOutro,
            // CS
            "csInformadaSim": csInformadaSim, "csInformadaNao": csInformadaNao,
            // Relatório
            "relatorioAutoridade": relatorioAutoridade,
            "signatureResponsible": sigResponsible?.base64String ?? ""
        ]
        
        // Beach-specific conditions
        if !isPool {
            formData["condVentoFraco"] = condVentoFraco
            formData["condVentoMod"] = condVentoMod
            formData["condVentoForte"] = condVentoForte
            formData["condVisibMa"] = condVisibMa
            formData["condVisibMedia"] = condVisibMedia
            formData["condVisibBoa"] = condVisibBoa
            formData["condCorrenteForte"] = condCorrenteForte
            formData["condCorrenteMedia"] = condCorrenteMedia
            formData["condCorrenteFraca"] = condCorrenteFraca
            formData["condMareEnch"] = condMareEnch
            formData["condMareVaz"] = condMareVaz
            formData["condOndulacao1m"] = condOndulacao1m
            formData["condOndulacao1a2m"] = condOndulacao1a2m
            formData["condOndulacao2a3m"] = condOndulacao2a3m
            formData["condOndulacaoOutro"] = condOndulacaoOutro
            formData["condBandVerde"] = condBandVerde
            formData["condBandAmarela"] = condBandAmarela
            formData["condBandVerm"] = condBandVerm
            formData["condBandSem"] = condBandSem
        }
        
        // Beach-specific means & evacuation
        if !isPool {
            formData["meioEmbarcacao"] = meioEmbarcacao
            formData["meioMotaAgua"] = meioMotaAgua
            formData["meioBoiaTorpedo"] = meioBoiaTorpedo
            formData["meioMoto4x4"] = meioMoto4x4
            formData["meioViatura4x4"] = meioViatura4x4
            formData["meioPrancha"] = meioPrancha
            formData["meioGoes"] = meioGoes
            formData["evacEmbCap"] = evacEmbCap
            formData["evacViatCap"] = evacViatCap
            formData["evacHeliFAP"] = evacHeliFAP
            formData["evacHeliCNBCP"] = evacHeliCNBCP
        } else {
            formData["meioVara"] = meioVara
            formData["meioPlanoRigido"] = meioPlanoRigido
            // Pool-specific causes
            formData["causaAVC"] = causaAVC
            formData["causaAngina"] = causaAngina
            formData["causaEnfarte"] = causaEnfarte
            formData["causaChoque"] = causaChoque
            formData["causaHemorragia"] = causaHemorragia
            formData["causaParagemDigestiva"] = causaParagemDigestiva
            formData["causaQueimadura"] = causaQueimadura
            formData["causaGolpeCalor"] = causaGolpeCalor
            formData["causaCefaleias"] = causaCefaleias
            formData["traumaVertebro"] = traumaVertebro
            formData["traumaCranio"] = traumaCranio
            formData["traumaMusculo"] = traumaMusculo
            formData["traumaQueda"] = traumaQueda
            formData["causaDiabetica"] = causaDiabetica
            formData["causaEpileptica"] = causaEpileptica
            formData["causaPicada"] = causaPicada
            formData["causaFeridas"] = causaFeridas
            formData["causaOutra"] = causaOutra
            // Pool typology
            formData["tipoMunCob"] = tipoMunCob
            formData["tipoMunDes"] = tipoMunDes
            formData["tipoMunNat"] = tipoMunNat
            formData["tipoHotCob"] = tipoHotCob
            formData["tipoHotDes"] = tipoHotDes
            formData["tipoHotAq"] = tipoHotAq
            formData["tipoDespCob"] = tipoDespCob
            formData["tipoDespDes"] = tipoDespDes
            formData["tipoPrivCob"] = tipoPrivCob
            formData["tipoPrivDes"] = tipoPrivDes
            formData["tipoCampCob"] = tipoCampCob
            formData["tipoCampDes"] = tipoCampDes
            formData["tipoEscCob"] = tipoEscCob
            formData["tipoEscDes"] = tipoEscDes
            formData["tipoOutra"] = tipoOutraStr
        }
        
        let body: [String: Any] = [
            "submitterId": user.id,
            "submitterName": user.name,
            "servicoId": selectedServicoId,
            "type": reportType.rawValue,
            "submissionDate": ISO8601DateFormatter().string(from: Date()),
            "formData": formData
        ]
        
        do {
            let _ = try await APIService.shared.addReport(body)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            isSaving = false
            withAnimation { showSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
        } catch {
            isSaving = false
            // TODO: Save offline
        }
    }
}
