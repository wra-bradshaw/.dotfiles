{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then
      (pkgs.brewCasks."firefox".overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs
          ++ [ pkgs.xmlstarlet pkgs.darwin.sigtool pkgs.makeWrapper ];
        fixupPhase = ''
          xmlstarlet ed -L -s "//key[contains(text(), 'LSEnvironment')]/following-sibling::dict[1]" -t "elem" -n "key" -v "MOZ_LEGACY_PROFILES" "$out/Applications/Firefox.app/Contents/Info.plist"
          xmlstarlet ed -L -s "//key[contains(text(), 'LSEnvironment')]/following-sibling::dict[1]" -t "elem" -n "string" -v "true" "$out/Applications/Firefox.app/Contents/Info.plist"
          makeWrapper "$out/Applications/Firefox.app/Contents/MacOS/firefox" "$out/bin/firefox" --set MOZ_LEGACY_PROFILES "true"
          codesign -f -s - "$out/Applications/Firefox.app/Contents/MacOS/firefox"
        '';
      }))
    else
      pkgs.firefox;
    profiles.default = {
      settings = {
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "about:blank";
        "media.ffmpeg.vaapi.enabled" = true;
        "signon.rememberSignons" = false;
        "extensions.autoDisableScopes" = 0;
        "extensions.pocket.enabled" = false;
        "identity.fxaccounts.enabled" = false;
        "app.update.auto" = false;
        "browser.warnOnQuit" = false;
        "browser.warnOnQuitShortcut" = false;

        # fastfox things
        "content.notify.interval" = 1000;
        "gfx.canvas.accelerated.cache-items" = 4096;
        "gfx.canvas.accelerated.cache-size" = 512;
        "gfx.content.skia-font-cache-size" = 20;
        "browser.cache.jsbc_compression_level" = 3;
        "media.memory_cache_max_size" = 65536;
        "media.cache_readahead_limit" = 7200;
        "media.cache_resume_threshold" = 3600;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.pacing.requests.enabled" = false;
        "network.dnsCacheExpiration" = 3600;
        "network.ssl_tokens_cache_capacity" = 10240;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.prefetch-next" = false;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        "dom.enable_web_task_scheduling" = true;
        "dom.security.sanitizer.enabled" = true;

        # securefox things
        "browser.contentblocking.category" = "strict";
        "browser.uitour.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "dom.security.https_first" = true;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # peskyfox things
        "browser.privatebrowsing.vpnpromourl" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
      };
      containersForce = true;
      containers = {
        work = {
          id = 1;
          icon = "briefcase";
          color = "orange";
        };
        personal = {
          id = 2;
          icon = "fingerprint";
          color = "blue";
        };
      };
      extensions = with config.nur.repos.rycee.firefox-addons; [
        multi-account-containers
        firefox-translations
        vimium
        bitwarden
        british-english-dictionary-2
        (buildFirefoxXpiAddon {
          pname = "what-to-click";
          version = "1.12.5";
          addonId = "{7feef224-a737-4d04-b0c1-ea47d4cad70a}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4159230/what_to_click-1.12.5.xpi";
          sha256 = "8eccdf9d8ece5cc759f77b7628201590d57a98cc8d2335666a38bfef87fc0e4e";
          meta = {};
        })
      ];
      search.force = true;
      search.engines = {
        "Will Lucky" = {
          urls = [{ template = "https://github.com/will-lol/{searchTerms}"; }];
          definedAliases = [ "@willl" ];
        };
        "Ionata WordPress Lucky" = {
          urls = [{
            template = "https://github.com/ionata/wp-theme-{searchTerms}";
          }];
          definedAliases = [ "@ionwpl" ];
        };
        "Ionata Lucky" = {
          urls = [{ template = "https://github.com/ionata/{searchTerms}"; }];
          definedAliases = [ "@ionl" ];
        };
        "Ionata" = {
          urls = [{
            template =
              "https://github.com/search?q=org%3Aionata%20{searchTerms}&type=repositories";
          }];
          definedAliases = [ "@ion" ];
        };
        "Reddit - subreddit" = {
          urls = [{ template = "https://www.reddit.com/r/{searchTerms}"; }];
          definedAliases = [ "r/" ];
        };
        "Reddit" = {
          urls =
            [{ template = "https://www.reddit.com/search/?q={searchTerms}"; }];
          definedAliases = [ "@reddit" ];
        };
        "Github" = {
          urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
          definedAliases = [ "@github" ];
        };
        "Dictionary" = {
          urls = [{
            template = "https://www.oed.com/search/dictionary/?q={searchTerms}";
          }];
          definedAliases = [ "@dict" ];
        };
        "es" = {
          urls = [{
            template =
              "https://translate.google.com/?sl=es&tl=en&text={searchTerms}&op=translate";
          }];
          definedAliases = [ "@es" ];
        };
        "en" = {
          urls = [{
            template =
              "https://translate.google.com/?sl=en&tl=es&text={searchTerms}&op=translate";
          }];
          definedAliases = [ "@en" ];
        };
      };
    };
  };
}
