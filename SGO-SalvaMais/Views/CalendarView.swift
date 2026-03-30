import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var servicosVM: ServicosViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]
    
    private var shiftsForSelectedDate: [Shift] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)
        return servicosVM.shifts.filter { $0.date.prefix(10) == dateStr }
    }
    
    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = (calendar.component(.weekday, from: firstDay) + 5) % 7 // Monday = 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    private func hasShifts(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        return servicosVM.shifts.contains { $0.date.prefix(10) == dateStr }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Month navigation
                        monthNavigation
                        
                        // Calendar Grid
                        calendarGrid
                        
                        // Shifts for selected day
                        shiftsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Calendário")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if let firstServico = servicosVM.servicos.first {
                    await servicosVM.fetchShifts(for: firstServico.id)
                }
            }
        }
    }
    
    // MARK: - Month Navigation
    
    private var monthNavigation: some View {
        HStack {
            Button {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)! }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.sgoTextPrimary)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.7)))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.sgoTextPrimary)
                
                Text(yearString)
                    .font(.system(size: 9, weight: .black))
                    .tracking(4)
                    .foregroundColor(.sgoRed)
            }
            
            Spacer()
            
            Button {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.sgoTextPrimary)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.7)))
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: currentMonth).capitalized
    }
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: currentMonth)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Day headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .black))
                        .tracking(1)
                        .foregroundColor(.sgoTextMuted)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let hasShift = hasShifts(on: date)
                        
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                            let gen = UISelectionFeedbackGenerator()
                            gen.selectionChanged()
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 15, weight: isSelected ? .black : .medium))
                                    .foregroundColor(isSelected ? .white : isToday ? .sgoRed : .sgoTextPrimary)
                                
                                if hasShift {
                                    Circle()
                                        .fill(isSelected ? Color.white : Color.sgoRed)
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.sgoRed : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(16)
        .sgoGlassCard(cornerRadius: 24)
    }
    
    // MARK: - Shifts Section
    
    private var shiftsSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(
                title: dateString(selectedDate),
                subtitle: "\(shiftsForSelectedDate.count) Escalas"
            )
            
            if shiftsForSelectedDate.isEmpty {
                VStack(spacing: 12) {
                    Text("📅")
                        .font(.system(size: 32))
                        .grayscale(0.5)
                        .opacity(0.4)
                    Text("Sem escalas neste dia")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.sgoTextMuted)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .sgoGlassCard(cornerRadius: 20)
            } else {
                ForEach(shiftsForSelectedDate) { shift in
                    HStack(spacing: 14) {
                        VStack {
                            Text(shift.startTime ?? "—")
                                .font(.system(size: 13, weight: .bold))
                            Text(shift.endTime ?? "—")
                                .font(.system(size: 11))
                                .foregroundColor(.sgoTextMuted)
                        }
                        .frame(width: 50)
                        
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.sgoRed)
                            .frame(width: 3, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(shift.lifeguardName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.sgoTextPrimary)
                            
                            Text(shift.shiftType)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.sgoTextMuted)
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                        
                        Spacer()
                    }
                    .padding(14)
                    .sgoGlassCard(cornerRadius: 18)
                }
            }
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}
