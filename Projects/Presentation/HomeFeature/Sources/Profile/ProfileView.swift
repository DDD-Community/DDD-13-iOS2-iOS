import SwiftUI

import ComposableArchitecture
import DesignSystem
import Entity

public struct ProfileView: View {
    @Bindable private var store: StoreOf<ProfileFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { dismiss() },
                title: "프로필"
            )

            ProfileContent(store: store)
        }
        .background(Colors.gray200.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { store.send(.onAppear) }
        .bottomSheet(
            isPresented: departurePlaceSheetBinding,
            header: .init(
                title: "출발지 수정",
                onClose: { store.send(.departurePlaceSheetDismissed) }
            )
        ) {
            DeparturePlaceEditSheetContent(
                departurePlaces: store.departurePlaces,
                onSelect: { store.send(.defaultDeparturePlaceSelected($0)) },
                onEdit: { store.send(.editDeparturePlaceTapped($0)) },
                onAdd: { store.send(.addDeparturePlaceTapped) }
            )
        }
    }

    private var departurePlaceSheetBinding: Binding<Bool> {
        Binding(
            get: { store.isDeparturePlaceSheetPresented },
            set: { isPresented in
                if !isPresented {
                    store.send(.departurePlaceSheetDismissed)
                }
            }
        )
    }
}

private struct ProfileContent: View {
    let store: StoreOf<ProfileFeature>

    var body: some View {
        if store.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage, store.profile == nil {
            ProfileLoadError(
                message: errorMessage,
                onRetry: { store.send(.retryButtonTapped) }
            )
        } else if let profile = store.profile {
            LoadedProfileContent(store: store, profile: profile)
        }
    }
}

private struct LoadedProfileContent: View {
    let store: StoreOf<ProfileFeature>
    let profile: MemberProfile

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Avatar(
                        avatarType: profile.profileImageURL
                            .flatMap(URL.init(string:))
                            .map(Avatar.AvatarType.image)
                            ?? .placeholder,
                        size: .s124
                    )
                    .padding(.top, Spacing.spacing400)

                    BangawoButton(
                        "프로필 수정",
                        variant: .weak,
                        size: .small
                    ) {
                        store.send(.editProfileButtonTapped)
                    }
                    .padding(.top, Spacing.spacing250)

                    ProfileInformationCard(
                        profile: profile,
                        defaultDeparturePlace: store.defaultDeparturePlace,
                        onDeparturePlaceTapped: { store.send(.departurePlaceRowTapped) }
                    )
                    .padding(.top, Spacing.spacing500)
                    .padding(.horizontal, Spacing.spacing400)
                }
            }

            TextButton(
                "로그아웃",
                size: .small,
                isDisabled: store.isLoggingOut
            ) {
                store.send(.logoutButtonTapped)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, Spacing.spacing400)
            .padding(.bottom, Spacing.spacing400)
        }
    }
}

private struct ProfileInformationCard: View {
    let profile: MemberProfile
    let defaultDeparturePlace: DeparturePlace?
    let onDeparturePlaceTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileInformationRow(title: "이름", value: profile.nickname)

            Divider()
                .foregroundStyle(Colors.gray300)
                .padding(.horizontal, Spacing.spacing300)

            Button(action: onDeparturePlaceTapped) {
                HStack(spacing: Spacing.spacing250) {
                    VStack(alignment: .leading, spacing: Spacing.spacing100) {
                        BangawoText("기본 출발지", textStyle: .bodySmall)
                            .foregroundStyle(Colors.gray600)

                        BangawoText(
                            defaultDeparturePlace?.placeName ?? "등록된 출발지가 없습니다.",
                            textStyle: .bodyLargeEmphasized
                        )
                        .foregroundStyle(Colors.gray900)

                        if let roadAddress = defaultDeparturePlace?.roadAddress {
                            BangawoText(roadAddress, textStyle: .bodySmall)
                                .foregroundStyle(Colors.gray700)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image.Asset.icArrowSmallRight24
                        .renderingMode(.template)
                        .foregroundStyle(Colors.gray600)
                }
                .padding(Spacing.spacing400)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .fill(Colors.gray00)
        )
    }
}

private struct ProfileInformationRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText(title, textStyle: .bodySmall)
                .foregroundStyle(Colors.gray600)

            BangawoText(value, textStyle: .bodyLargeEmphasized)
                .foregroundStyle(Colors.gray900)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.spacing400)
    }
}

private struct ProfileLoadError: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.spacing300) {
            BangawoText(message, textStyle: .bodyMedium)
                .foregroundStyle(Colors.gray700)

            BangawoButton("다시 시도", variant: .weak, size: .small, action: onRetry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
