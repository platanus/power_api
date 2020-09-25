RSpec.describe PowerApi::GeneratorHelper::ControllerActionsHelper, type: :generator do
  describe '#controller_actions=' do
    context 'when arg is nil' do
      before { generators_helper.controller_actions = nil }

      it do
        expect(generators_helper.controller_actions).to(
          match_array(generators_helper.class::PERMITTED_ACTIONS)
        )
      end
    end

    context 'when arg is empty array' do
      before { generators_helper.controller_actions = [] }

      it do
        expect(generators_helper.controller_actions).to(
          match_array(generators_helper.class::PERMITTED_ACTIONS)
        )
      end
    end

    context 'when including not permitted actions' do
      before { generators_helper.controller_actions = ['index', 'clone'] }

      it 'ignores them' do
        expect(generators_helper.controller_actions).to match_array(['index'])
      end
    end

    context 'when including only permitted actions' do
      let(:actions) { ['index', 'show'] }

      before { generators_helper.controller_actions = actions }

      it 'includes them all' do
        expect(generators_helper.controller_actions).to match_array(actions)
      end
    end
  end

  describe 'index?' do
    context 'when including index action' do
      before { generators_helper.controller_actions = ['index'] }

      it { expect(generators_helper.index?).to be(true) }
    end

    context 'when not including index action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.index?).to be(false) }
    end
  end

  describe 'show?' do
    context 'when including show action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.show?).to be(true) }
    end

    context 'when not including show action' do
      before { generators_helper.controller_actions = ['index'] }

      it { expect(generators_helper.show?).to be(false) }
    end
  end

  describe 'update?' do
    context 'when including update action' do
      before { generators_helper.controller_actions = ['update'] }

      it { expect(generators_helper.update?).to be(true) }
    end

    context 'when not including update action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.update?).to be(false) }
    end
  end

  describe 'create?' do
    context 'when including create action' do
      before { generators_helper.controller_actions = ['create'] }

      it { expect(generators_helper.create?).to be(true) }
    end

    context 'when not including create action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.create?).to be(false) }
    end
  end

  describe 'destroy?' do
    context 'when including destroy action' do
      before { generators_helper.controller_actions = ['destroy'] }

      it { expect(generators_helper.destroy?).to be(true) }
    end

    context 'when not including destroy action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.destroy?).to be(false) }
    end
  end

  describe 'resource_actions?' do
    context 'when including show action' do
      before { generators_helper.controller_actions = ['show'] }

      it { expect(generators_helper.resource_actions?).to be(true) }
    end

    context 'when including update action' do
      before { generators_helper.controller_actions = ['update'] }

      it { expect(generators_helper.resource_actions?).to be(true) }
    end

    context 'when including destroy action' do
      before { generators_helper.controller_actions = ['destroy'] }

      it { expect(generators_helper.resource_actions?).to be(true) }
    end

    context 'when not including show, update or destroy actions' do
      before { generators_helper.controller_actions = ['index', 'create'] }

      it { expect(generators_helper.resource_actions?).to be(false) }
    end
  end

  describe 'collection_actions?' do
    context 'when including index action' do
      before { generators_helper.controller_actions = ['index'] }

      it { expect(generators_helper.collection_actions?).to be(true) }
    end

    context 'when including create action' do
      before { generators_helper.controller_actions = ['create'] }

      it { expect(generators_helper.collection_actions?).to be(true) }
    end

    context 'when not including index or create actions' do
      before { generators_helper.controller_actions = ['show', 'update', 'destroy'] }

      it { expect(generators_helper.collection_actions?).to be(false) }
    end
  end

  describe 'update_or_create?' do
    context 'when including update action' do
      before { generators_helper.controller_actions = ['update'] }

      it { expect(generators_helper.update_or_create?).to be(true) }
    end

    context 'when including create action' do
      before { generators_helper.controller_actions = ['create'] }

      it { expect(generators_helper.update_or_create?).to be(true) }
    end

    context 'when not including update or create actions' do
      before { generators_helper.controller_actions = ['show', 'index', 'destroy'] }

      it { expect(generators_helper.update_or_create?).to be(false) }
    end
  end
end
