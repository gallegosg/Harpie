//
//  RewardedViewModel.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 3/7/25.
//

import GoogleMobileAds

class RewardedViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    private var rewardedAd: RewardedAd?
    private let playlistManager = PlaylistLimitManager()

    func loadAd() async {
        do {            
            rewardedAd = try await RewardedAd.load(
                with: K.adUnitId, request: Request())
            rewardedAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
      guard let rewardedAd = rewardedAd else {
        return print("Ad wasn't ready.")
      }

      rewardedAd.present(from: nil) {
        let reward = rewardedAd.adReward
        print("Reward amount: \(reward.amount)")
        self.playlistManager.addPlaylistAllowance()
      }
    }

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(
      _ ad: FullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("\(#function) called")
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
      // Clear the rewarded ad.
      rewardedAd = nil
    }
}
