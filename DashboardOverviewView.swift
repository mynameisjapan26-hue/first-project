import SwiftUI

// MARK: - Models

enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
}

struct MetricItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let changePercentage: String
    let isPositive: Bool
    let systemImage: String
    let tintColor: Color
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let timestamp: String
    let systemImage: String
    let amount: String?
}

// MARK: - Main View

/// A responsive, accessible dashboard overview view displaying key metrics and recent activity.
struct DashboardOverviewView: View {
    @State private var selectedPeriod: TimePeriod = .week
    @State private var isBookmarked: Bool = false
    @State private var isAppeared: Bool = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    periodPicker
                    metricsGrid
                    recentActivitySection
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    bookmarkButton
                }
            }
            .onAppear {
                guard !isAppeared else { return }
                if reduceMotion {
                    isAppeared = true
                } else {
                    withAnimation(.easeOut(duration: 0.45)) {
                        isAppeared = true
                    }
                }
            }
        }
    }
    
    // MARK: - Extracted Main Sections
    
    private var headerSection: some View {
        UserProfileHeaderView(
            name: "Alex Morgan",
            role: "Product Lead",
            avatarSystemImage: "person.crop.circle.fill"
        )
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared || reduceMotion ? 0 : 12)
    }
    
    private var periodPicker: some View {
        Picker("Time Period", selection: $selectedPeriod) {
            ForEach(TimePeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared || reduceMotion ? 0 : 16)
    }
    
    private var metricsGrid: some View {
        MetricsGridView(metrics: currentMetrics)
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared || reduceMotion ? 0 : 20)
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75), value: selectedPeriod)
    }
    
    private var recentActivitySection: some View {
        RecentActivitySection(activities: sampleActivities)
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared || reduceMotion ? 0 : 24)
    }
    
    private var bookmarkButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isBookmarked.toggle()
            }
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundStyle(isBookmarked ? Color.accentColor : Color.secondary)
        }
        .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark dashboard")
    }
    
    // MARK: - Dynamic Data by Period
    
    private var currentMetrics: [MetricItem] {
        switch selectedPeriod {
        case .week:
            return [
                MetricItem(title: "Revenue", value: "$12,450", changePercentage: "+14.2%", isPositive: true, systemImage: "chart.line.uptrend.xyaxis", tintColor: .blue),
                MetricItem(title: "Active Users", value: "3,820", changePercentage: "+8.1%", isPositive: true, systemImage: "person.2.fill", tintColor: .green),
                MetricItem(title: "Conversion", value: "3.4%", changePercentage: "-0.5%", isPositive: false, systemImage: "arrow.triangle.swap", tintColor: .orange),
                MetricItem(title: "Avg. Session", value: "4m 12s", changePercentage: "+12.0%", isPositive: true, systemImage: "clock.fill", tintColor: .purple)
            ]
        case .month:
            return [
                MetricItem(title: "Revenue", value: "$48,920", changePercentage: "+22.4%", isPositive: true, systemImage: "chart.line.uptrend.xyaxis", tintColor: .blue),
                MetricItem(title: "Active Users", value: "15,200", changePercentage: "+16.8%", isPositive: true, systemImage: "person.2.fill", tintColor: .green),
                MetricItem(title: "Conversion", value: "3.8%", changePercentage: "+0.4%", isPositive: true, systemImage: "arrow.triangle.swap", tintColor: .orange),
                MetricItem(title: "Avg. Session", value: "4m 38s", changePercentage: "+18.5%", isPositive: true, systemImage: "clock.fill", tintColor: .purple)
            ]
        case .year:
            return [
                MetricItem(title: "Revenue", value: "$582,000", changePercentage: "+34.5%", isPositive: true, systemImage: "chart.line.uptrend.xyaxis", tintColor: .blue),
                MetricItem(title: "Active Users", value: "142,500", changePercentage: "+28.2%", isPositive: true, systemImage: "person.2.fill", tintColor: .green),
                MetricItem(title: "Conversion", value: "4.1%", changePercentage: "+1.1%", isPositive: true, systemImage: "arrow.triangle.swap", tintColor: .orange),
                MetricItem(title: "Avg. Session", value: "5m 04s", changePercentage: "+24.0%", isPositive: true, systemImage: "clock.fill", tintColor: .purple)
            ]
        }
    }
    
    private var sampleActivities: [ActivityItem] {
        [
            ActivityItem(title: "Pro Subscription", subtitle: "Stripe checkout • Monthly", timestamp: "12m ago", systemImage: "creditcard.fill", amount: "+$29.00"),
            ActivityItem(title: "New Team Member", subtitle: "sarah@design.co joined", timestamp: "1h ago", systemImage: "person.badge.plus", amount: nil),
            ActivityItem(title: "Cloud Backup Sync", subtitle: "Automated database snapshot", timestamp: "3h ago", systemImage: "arrow.clockwise.icloud.fill", amount: nil)
        ]
    }
}

// MARK: - Subviews

struct UserProfileHeaderView: View {
    let name: String
    let role: String
    let avatarSystemImage: String
    
    @ScaledMetric(relativeTo: .title) private var avatarSize: CGFloat = 48
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: avatarSystemImage)
                .resizable()
                .scaledToFit()
                .frame(width: avatarSize, height: avatarSize)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text(role)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            StatusBadge(text: "Live", isOnline: true)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(role), Status: Live")
    }
}

struct StatusBadge: View {
    let text: String
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOnline ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(Capsule())
    }
}

struct MetricsGridView: View {
    let metrics: [MetricItem]
    
    // Adaptive grid reflows automatically on rotation or wider screens (e.g. iPad, landscape iPhone)
    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 14)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(metrics) { metric in
                MetricCardView(metric: metric)
            }
        }
    }
}

struct MetricCardView: View {
    let metric: MetricItem
    @ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 18
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: metric.systemImage)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(metric.tintColor)
                
                Spacer()
                
                Text(metric.changePercentage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(metric.isPositive ? Color.green : Color.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.primary)
                    .contentTransition(.numericText())
                
                Text(metric.title)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metric.title): \(metric.value), \(metric.isPositive ? "Up" : "Down") \(metric.changePercentage)")
    }
}

struct RecentActivitySection: View {
    let activities: [ActivityItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                Button("See All") {}
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHint("Opens full activity history")
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    ActivityRowView(activity: activity)
                    
                    if index < activities.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct ActivityRowView: View {
    let activity: ActivityItem
    @ScaledMetric(relativeTo: .body) private var iconBoxSize: CGFloat = 36
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(uiColor: .tertiarySystemFill))
                    .frame(width: iconBoxSize, height: iconBoxSize)
                
                Image(systemName: activity.systemImage)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.primary)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if let amount = activity.amount {
                    Text(amount)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.primary)
                }
                
                Text(activity.timestamp)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.title), \(activity.subtitle), \(activity.timestamp)\(activity.amount != nil ? ", \(activity.amount!)" : "")")
    }
}

// MARK: - Preview

#Preview {
    DashboardOverviewView()
}
