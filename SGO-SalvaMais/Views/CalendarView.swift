import SwiftUI

// MARK: - Calendar View Mode

enum CalendarMode: String, CaseIterable {
    case monthly = "Mês"
    case weekly  = "Semana"
    case daily   = "Dia"
}

// MARK: - Calendar View

struct CalendarView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var servicosVM: ServicosViewModel
    @State private var selectedDate = Date()
    @State private var currentDate = Date()
    @State private var mode: CalendarMode = .weekly
    @State private var selectedServicoId: String? = nil
    @State private var isLoadingShifts = false

    private let calendar = Calendar.current
    private let daysOfWeekPT = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]

    // MARK: - Computed

    private var servicos: [Servico] { servicosVM.servicos }

    private var filteredShifts: [Shift] {
        guard let sid = selectedServicoId else { return servicosVM.shifts }
        return servicosVM.shifts.filter { $0.servicoId == sid }
    }

    private func shiftsFor(_ date: Date) -> [Shift] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let ds = fmt.string(from: date)
        return filteredShifts.filter { $0.date.prefix(10) == ds }
    }

    private var shiftsForSelectedDate: [Shift] { shiftsFor(selectedDate) }

    private var weekDays: [Date] {
        let weekday = calendar.component(.weekday, from: currentDate) - 1 // 0=Sun
        let sunday = calendar.date(byAdding: .day, value: -weekday, to: currentDate)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }

    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1 // 0=Sun
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstDay) { days.append(d) }
        }
        return days
    }

    private func hasShifts(on date: Date) -> Bool {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return filteredShifts.contains { $0.date.prefix(10) == fmt.string(from: date) }
    }

    private var weekNumber: Int {
        calendar.component(.weekOfMonth, from: currentDate)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Dark header card (PC-style)
                        headerCard
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        // Content
                        VStack(spacing: 16) {
                            switch mode {
                            case .monthly: monthView
                            case .weekly:  weekView
                            case .daily:   dayView
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Escalas & Agenda")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadShiftsForAll()
            }
        }
    }

    // MARK: - Header Card (dark, PC-style)

    private var headerCard: some View {
        VStack(spacing: 14) {
            // Month/week nav
            HStack {
                Button {
                    withAnimation { navigateBack() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(headerTitle.uppercased())
                        .font(.system(size: 18, weight: .light)).foregroundColor(.white)
                    Text(headerSubtitle)
                        .font(.system(size: 10, weight: .black)).tracking(3).foregroundColor(.sgoRed)
                }
                Spacer()
                Button {
                    withAnimation { navigateForward() }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
            }

            // Filters row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Posto selector
                    Menu {
                        Button("Todos os Postos") { selectedServicoId = nil }
                        ForEach(servicos) { s in
                            Button(s.name) { selectedServicoId = s.id }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(servicos.first(where: { $0.id == selectedServicoId })?.name ?? "Todos os Postos")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9)).foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                        .overlay(Capsule().stroke(selectedServicoId != nil ? Color.sgoRed : Color.white.opacity(0.2), lineWidth: 1))
                    }

                    // Mode selector
                    HStack(spacing: 0) {
                        ForEach(CalendarMode.allCases, id: \.self) { m in
                            Button {
                                withAnimation { mode = m }
                            } label: {
                                Text(m.rawValue.uppercased())
                                    .font(.system(size: 10, weight: .black)).tracking(0.5)
                                    .foregroundColor(mode == m ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(mode == m ? Color.sgoRed : Color.clear)
                                    )
                            }
                        }
                    }
                    .background(Capsule().fill(Color.white.opacity(0.08)))

                    // HOJE button
                    Button {
                        withAnimation {
                            selectedDate = Date()
                            currentDate = Date()
                        }
                    } label: {
                        Text("HOJE")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.sgoBlack)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.sgoBlack)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
        )
    }

    // MARK: - Header text helpers

    private var headerTitle: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_PT")
        switch mode {
        case .monthly:
            fmt.dateFormat = "MMMM 'DE' yyyy"
            return fmt.string(from: currentDate).uppercased()
        case .weekly:
            fmt.dateFormat = "MMMM 'DE' yyyy"
            return fmt.string(from: currentDate).uppercased()
        case .daily:
            fmt.dateFormat = "d 'DE' MMMM yyyy"
            return fmt.string(from: selectedDate).uppercased()
        }
    }

    private var headerSubtitle: String {
        switch mode {
        case .monthly: return yearString(currentDate)
        case .weekly:  return "SEMANA \(weekNumber)"
        case .daily:   return weekdayString(selectedDate).uppercased()
        }
    }

    private func navigateBack() {
        switch mode {
        case .monthly: currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        case .weekly:  currentDate = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        case .daily:   selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!; currentDate = selectedDate
        }
    }

    private func navigateForward() {
        switch mode {
        case .monthly: currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        case .weekly:  currentDate = calendar.date(byAdding: .day, value: 7, to: currentDate)!
        case .daily:   selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!; currentDate = selectedDate
        }
    }

    // MARK: - Month View

    private var monthView: some View {
        VStack(spacing: 16) {
            // Day headers
            VStack(spacing: 8) {
                HStack {
                    ForEach(daysOfWeekPT, id: \.self) { day in
                        Text(day.uppercased())
                            .font(.system(size: 9, weight: .black)).tracking(1)
                            .foregroundColor(.sgoTextMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                LazyVGrid(columns: cols, spacing: 4) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            let isSel = calendar.isDate(date, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(date)
                            let hasShift = hasShifts(on: date)
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedDate = date }
                                UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                VStack(spacing: 3) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 14, weight: isSel ? .black : .medium))
                                        .foregroundColor(isSel ? .white : isToday ? .sgoRed : .sgoTextPrimary)
                                    Circle().fill(isSel ? Color.white : hasShift ? Color.sgoRed : Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                                .frame(maxWidth: .infinity).frame(height: 42)
                                .background(RoundedRectangle(cornerRadius: 12).fill(isSel ? Color.sgoRed : Color.clear))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear.frame(height: 42)
                        }
                    }
                }
            }
            .padding(16).sgoGlassCard(cornerRadius: 24)

            shiftsSection
        }
    }

    // MARK: - Week View

    private var weekView: some View {
        VStack(spacing: 16) {
            // 7 day cards
            HStack(spacing: 6) {
                ForEach(weekDays, id: \.self) { day in
                    let isSel = calendar.isDate(day, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(day)
                    let count = shiftsFor(day).count
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = day; currentDate = day
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        VStack(spacing: 4) {
                            Text(shortWeekday(day))
                                .font(.system(size: 9, weight: .black)).tracking(0.5)
                                .foregroundColor(isSel ? .white : .sgoTextMuted)
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 16, weight: isSel ? .black : .medium))
                                .foregroundColor(isSel ? .white : isToday ? .sgoRed : .sgoTextPrimary)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(isSel ? .white : .sgoRed)
                            } else {
                                Spacer().frame(height: 12)
                            }
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSel ? Color.sgoRed : Color.white.opacity(0.6))
                                .shadow(color: isSel ? Color.sgoRed.opacity(0.3) : .clear, radius: 8, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            shiftsSection
        }
    }

    // MARK: - Day View

    private var dayView: some View {
        VStack(spacing: 16) {
            if isLoadingShifts {
                ProgressView().tint(.sgoRed).padding(32)
            } else if shiftsForSelectedDate.isEmpty {
                VStack(spacing: 12) {
                    Text("📅").font(.system(size: 44)).grayscale(0.5).opacity(0.4)
                    Text("Sem escalas neste dia")
                        .font(.system(size: 14, weight: .medium)).foregroundColor(.sgoTextMuted)
                }
                .padding(40).frame(maxWidth: .infinity).sgoGlassCard(cornerRadius: 24)
            } else {
                ForEach(shiftsForSelectedDate) { shift in
                    dailyShiftCard(shift)
                }
            }
        }
    }

    // MARK: - Shifts Section (shared)

    private var shiftsSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(
                title: dateString(selectedDate),
                subtitle: "\(shiftsForSelectedDate.count) Escala(s)"
            )
            if isLoadingShifts {
                ProgressView().tint(.sgoRed).padding(20)
            } else if shiftsForSelectedDate.isEmpty {
                VStack(spacing: 10) {
                    Text("📅").font(.system(size: 28)).grayscale(0.5).opacity(0.4)
                    Text("Sem escalas neste dia")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.sgoTextMuted)
                }
                .padding(24).frame(maxWidth: .infinity).sgoGlassCard(cornerRadius: 20)
            } else {
                ForEach(shiftsForSelectedDate) { shift in shiftRow(shift) }
            }
        }
    }

    @ViewBuilder
    private func shiftRow(_ shift: Shift) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(shift.startTime ?? "—").font(.system(size: 13, weight: .bold))
                Text(shift.endTime ?? "—").font(.system(size: 11)).foregroundColor(.sgoTextMuted)
            }
            .frame(width: 48)
            RoundedRectangle(cornerRadius: 2).fill(Color.sgoRed).frame(width: 3, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(shift.lifeguardName)
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.sgoTextPrimary)
                Text(shift.shiftType.uppercased())
                    .font(.system(size: 9, weight: .black)).foregroundColor(.sgoTextMuted).tracking(1)
            }
            Spacer()
        }
        .padding(14).sgoGlassCard(cornerRadius: 18)
    }

    @ViewBuilder
    private func dailyShiftCard(_ shift: Shift) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(shift.startTime ?? "—")
                    .font(.system(size: 15, weight: .black)).foregroundColor(.sgoRed)
                RoundedRectangle(cornerRadius: 2).fill(Color.sgoRed.opacity(0.3))
                    .frame(width: 2).frame(maxHeight: .infinity)
                Text(shift.endTime ?? "—")
                    .font(.system(size: 12)).foregroundColor(.sgoTextMuted)
            }
            .frame(width: 52)
            VStack(alignment: .leading, spacing: 6) {
                Text(shift.lifeguardName)
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.sgoTextPrimary)
                HStack(spacing: 6) {
                    Text(shift.shiftType.uppercased())
                        .font(.system(size: 9, weight: .black)).tracking(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Color.sgoRed))
                }
                if let notes = shift.notes, !notes.isEmpty {
                    Text(notes).font(.system(size: 11)).foregroundColor(.sgoTextSecondary).lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(16).sgoGlassCard(cornerRadius: 20)
    }

    // MARK: - Helpers

    private func loadShiftsForAll() async {
        isLoadingShifts = true
        for servico in servicosVM.servicos {
            await servicosVM.fetchShifts(for: servico.id)
        }
        isLoadingShifts = false
    }

    private func yearString(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy"; return f.string(from: d)
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "pt_PT"); f.dateFormat = "d MMMM"
        return f.string(from: d)
    }

    private func weekdayString(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "pt_PT"); f.dateFormat = "EEEE"
        return f.string(from: d).capitalized
    }

    private func shortWeekday(_ d: Date) -> String {
        let w = calendar.component(.weekday, from: d)
        return ["DOM","SEG","TER","QUA","QUI","SEX","SÁB"][w - 1]
    }
}
