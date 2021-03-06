require "rails_helper"

describe Releaf::I18nDatabase::Backend do
  let(:translations_store){ Releaf::I18nDatabase::TranslationsStore.new }

  describe ".configure_component" do
    it "adds new `Releaf::I18nDatabase::Configuration` configuration with enabled missing translation creation" do
      allow(Releaf::I18nDatabase::Configuration).to receive(:new)
        .with(create_missing_translations: true).and_return("_new")
      expect(Releaf.application.config).to receive(:add_configuration).with("_new")
      described_class.configure_component
    end
  end

  describe ".initialize_component" do
    it "adds itself as i18n backend" do
      allow(described_class).to receive(:new).and_return("x")
      expect(I18n).to receive(:backend=).with("x")
      described_class.initialize_component
    end
  end

  describe "#translations" do
    let(:another_translations_store){ Releaf::I18nDatabase::TranslationsStore.new }

    context "when translations has been loaded and is not expired" do
      it "returns assigned translations hash instance" do
        subject.translations_cache = translations_store
        allow(translations_store).to receive(:expired?).and_return(false)
        expect(Releaf::I18nDatabase::TranslationsStore).to_not receive(:new)
        expect(subject.translations).to eq(translations_store)
      end
    end

    context "when translations has been loaded and is expired" do
      it "initializes new `TranslationsStore`, cache and return it" do
        subject.translations_cache = translations_store
        allow(translations_store).to receive(:expired?).and_return(true)
        expect(Releaf::I18nDatabase::TranslationsStore).to receive(:new).and_return(another_translations_store)
        expect(subject.translations).to eq(another_translations_store)
      end
    end

    context "when translations has not been loaded" do
      it "initializes new `TranslationsStore`, cache and return it" do
        subject.translations_cache = nil
        expect(Releaf::I18nDatabase::TranslationsStore).to receive(:new).and_return(another_translations_store)
        expect(subject.translations).to eq(another_translations_store)
      end
    end
  end

  describe "#store_translations" do
    it "merges given translations to cache" do
      allow(subject).to receive(:translations).and_return(translations_store)
      expect(translations_store).to receive(:add).with(:lv, a: "x")
      subject.store_translations(:lv, a: "x")
    end
  end

  describe "#default" do
    context "when `create_default: false` option exists" do
      it "adds `create_default: true` option and remove `create_default` option" do
        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true, create_missing: false)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true, create_default: false, create_missing: false)
      end

      it "does not change given options" do
        options = {count:1, default: "xxx", fallback: true, create_default: false}
        expect{ subject.send(:default, "en", "aa", "bb", options) }.to_not change{ options }
      end
    end

    context "when `create_default: false` option does not exists" do
      it "does not modify options" do
        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true)

        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true, create_default: true)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true, create_default: true)
      end
    end
  end

  describe ".translations_updated_at" do
    it "returns translations updated_at from cached settings" do
      allow(Releaf::Settings).to receive(:[]).with(described_class::UPDATED_AT_KEY).and_return("x")
      expect(described_class.translations_updated_at).to eq("x")
    end
  end

  describe ".translations_updated_at=" do
    it "stores translations updated_at to cached settings" do
      expect(Releaf::Settings).to receive(:[]=).with(described_class::UPDATED_AT_KEY, "xx")
      described_class.translations_updated_at = "xx"
    end
  end

  describe "#lookup" do
    before do
      allow(subject).to receive(:translations).and_return(translations_store)
      allow(subject).to receive(:normalize_flat_keys).with(:lv, "some.localization", "_scope_", ":")
        .and_return("xx.s.loc")
    end

    it "flattens key before passing further" do
      expect(translations_store).to receive(:missing?).with(:lv, "xx.s.loc")
      expect(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b")
      expect(translations_store).to receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")

      subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
    end

    context "when translation is known as missing" do
      it "does not make lookup in translation hash, does not mark it as missing and return nil" do
        allow(translations_store).to receive(:missing?).with(:lv, "xx.s.loc").and_return(true)
        expect(translations_store).to_not receive(:lookup)
        expect(translations_store).to_not receive(:missing)
        expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
      end
    end

    context "when translation is not known as missing" do
      before do
        allow(translations_store).to receive(:missing?).with(:lv, "xx.s.loc").and_return(false)
      end

      context "when lookup result is not nil" do
        before do
          allow(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b").and_return("x")
        end

        it "returns lookup result" do
          expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to eq("x")
        end

        it "does not mark translation as missing" do
          expect(translations_store).to_not receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")
          subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
        end
      end

      context "when lookup result is nil" do
        before do
          allow(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b").and_return(nil)
        end

        it "returns nil" do
          expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
        end

        it "marks translation as missing" do
          expect(translations_store).to receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")
          subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
        end
      end
    end
  end
end
