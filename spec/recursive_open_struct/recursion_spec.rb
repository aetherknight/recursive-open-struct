# frozen_string_literal: true

# rubocop:disable Security/MarshalLoad
require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe 'recursive behavior' do
    subject(:ros) { described_class.new(h) }

    let(:h) { { blah: { another: 'value' } } }

    it 'can convert the entire hash tree back into a hash' do
      blank_obj = Object.new
      h = { asdf: 'John Smith', foo: [{ bar: blank_obj }, { baz: nil }] }
      ros = described_class.new(h)

      expect(ros.to_h).to eq h
      expect(ros.to_hash).to eq h
    end

    it 'returns accessed hashes as RecursiveOpenStructs instead of hashes' do
      expect(ros.blah.another).to eq 'value'
    end

    it 'handles subscript notation the same way as dotted notation' do
      expect(ros.blah.another).to eq ros[:blah].another
    end

    it 'uses #key_as_a_hash to return key as a Hash' do
      expect(ros.blah_as_a_hash).to eq({ another: 'value' })
    end

    it 'handles sub-element replacement with dotted notation before member setup' do
      expect(ros[:blah][:another]).to eql 'value'
      expect(ros.methods).not_to include(:blah)

      ros.blah = { changed: 'backing' }

      expect(ros.blah.changed).to eql 'backing'
    end

    it 'handles being dump then loaded by Marshal' do
      foo_struct = [described_class.new]
      bar_struct = described_class.new(foo: foo_struct)
      serialized = Marshal.dump(bar_struct)

      expect(Marshal.load(serialized).foo).to eq(foo_struct)
    end

    describe 'handling loops in the original Hashes' do
      subject(:ros) { described_class.new(h) }

      let(:nested_h) { { a: 'a' } }
      let(:h) { { a: 'b', nested_h: nested_h } }

      before { nested_h[:h] = h }

      it { expect(ros.nested_h.a).to eq 'a' }
      it { expect(ros.nested_h.h.a).to eq 'b' }
      it { expect(ros.nested_h.h.nested_h.a).to eq 'a' }
      it { expect(ros.nested_h.h.nested_h.h.a).to eq 'b' }
      it { expect(ros.nested_h).to eq ros.nested_h.h.nested_h }
      it { expect(ros.nested_h).not_to eq ros.nested_h.h }
    end # describe handling loops in the origin Hashes

    it 'can modify a key of a sub-element' do
      h = { blah: { blargh: 'Brad' } }
      ros = described_class.new(h)
      ros.blah.blargh = 'Janet'

      expect(ros.blah.blargh).to eq 'Janet'
    end

    describe 'subscript mutation notation' do
      let(:diff) { { different: 'thing' } }

      it 'handles the basic case' do
        ros[:blah] = 12_345
        expect(ros.blah).to be 12_345
      end

      it 'recurses properly' do
        ros[:blah][:another] = 'abc'
        expect(ros.blah.another).to eql 'abc'
        expect(ros.blah_as_a_hash).to eql({ another: 'abc' })
      end

      it 'can replace the entire hash' do
        expect(ros.to_h).to eql(h)
        ros[:blah] = diff
        expect(ros.to_h).to eql({ blah: diff })
      end

      it 'updates sub-element cache' do
        expect(ros.blah.different).to be_nil
        ros[:blah] = diff
        expect(ros.blah.different).to eql 'thing'
        expect(ros.blah_as_a_hash).to eql(diff)
      end
    end

    context 'when a sub-element has been modified' do
      subject(:ros) { described_class.new(hash) }

      let(:hash) do
        { blah: { blargh: 'Brad' }, some_array: [1, 2, 3] }
      end
      let(:updated_hash) do
        { blah: { blargh: 'Janet' }, some_array: [1, 2, 3] }
      end

      before { ros.blah.blargh = 'Janet' }

      describe '.to_h' do
        it 'returns a hash tree that contains those modifications' do
          expect(ros.to_h).to eq updated_hash
        end

        specify 'modifying the returned hash tree does not modify the ROS' do
          ros.to_h[:blah][:blargh] = 'Dr Scott'

          expect(ros.blah.blargh).to eq 'Janet'
        end
      end

      it 'does not mutate the original hash tree passed to the constructor' do
        expect(hash[:blah][:blargh]).to eq 'Brad'
      end

      it 'limits the deep-copy to the initial hash tree' do
        ros.some_array[0] = 4

        expect(hash[:some_array][0]).to eq 4
      end

      describe '#dup' do
        let(:duped_subject) { ros.dup }

        it 'preserves sub-element modifications' do
          expect(duped_subject.blah.blargh).to eq ros.blah.blargh
        end

        it "allows the copy's sub-elements to be modified independently from the original's" do
          expect(ros.blah.blargh).to eq 'Janet'

          duped_subject.blah.blargh = 'Dr. Scott'

          expect(ros.blah.blargh).to eq 'Janet'
          expect(duped_subject.blah.blargh).to eq 'Dr. Scott'
        end
      end
    end

    context 'when memoizing and then modifying entire recursive structures' do
      subject(:ros) do
        described_class.new(
          { blah: original_blah }, recurse_over_arrays: true
        )
      end

      before { ros.blah } # enforce memoization

      context 'when modifying an entire Hash' do
        let(:original_blah) { { a: 'A', b: 'B' } }
        let(:new_blah) { { something_new: 'C' } }

        before { ros.blah = new_blah }

        it 'returns the modified value instead of the memoized one' do
          expect(ros.blah.something_new).to eq 'C'
        end

        specify 'the old value no longer exists' do
          expect(ros.blah.a).to be_nil
        end
      end

      context 'when modifying an entire Array' do
        let(:original_blah) { [1, 2, 3] }

        it 'returns the modified value instead of the memoized one' do
          new_blah = [4, 5, 6]
          ros.blah = new_blah
          expect(ros.blah).to eq new_blah
        end
      end
    end

    describe 'recursing over arrays' do
      let(:blah_list) { [{ foo: '1' }, { foo: '2' }, 'baz'] }
      let(:h) { { blah: blah_list } }

      context 'when dump and loaded by Marshal' do
        subject(:ros) { Marshal.load(Marshal.dump(test)) }

        let(:test) { described_class.new(h, recurse_over_arrays: true) }

        it { expect(ros.blah.length).to eq 3 }
        it { expect(ros.blah[0].foo).to eq '1' }
        it { expect(ros.blah[1].foo).to eq '2' }
        it { expect(ros.blah_as_a_hash).to eq blah_list }
        it { expect(ros.blah[2]).to eq 'baz' }
      end

      context 'when recursing over arrays is enabled' do
        subject(:ros) { described_class.new(h, recurse_over_arrays: true) }

        it { expect(ros.blah.length).to eq 3 }
        it { expect(ros.blah[0].foo).to eq '1' }
        it { expect(ros.blah[1].foo).to eq '2' }
        it { expect(ros.blah_as_a_hash).to eq blah_list }
        it { expect(ros.blah[2]).to eq 'baz' }

        context 'when an inner value changes' do
          let(:updated_blah_list) { [{ foo: '1' }, { foo: 'Dr Scott' }, 'baz'] }
          let(:updated_h) { { blah: updated_blah_list } }

          before { ros.blah[1].foo = 'Dr Scott' }

          it 'Retains changes across Array lookups' do
            expect(ros.blah[1].foo).to eq 'Dr Scott'
          end

          it 'propagates the changes through to .to_h across Array lookups' do
            expect(ros.to_h).to eq({
                                     blah: [{ foo: '1' }, { foo: 'Dr Scott' }, 'baz']
                                   })
          end

          it 'deep-copies hashes within Arrays' do
            ros.to_h[:blah][1][:foo] = 'Rocky'

            expect(ros.blah[1].foo).to eq 'Dr Scott'
          end

          it 'does not mutate the input hash passed to the constructor (works when recursing over arrays too)' do
            expect(h[:blah][1][:foo]).to eq '2'
          end

          describe '#dup' do
            let(:duped_subject) { ros.dup }

            it 'preserves sub-element modifications' do
              expect(duped_subject.blah[1].foo).to eq ros.blah[1].foo
            end

            it "allows the copy's sub-elements to be modified independently from the original's" do
              duped_subject.blah[1].foo = 'Rocky'

              expect(duped_subject.blah[1].foo).to eq 'Rocky'
              expect(ros.blah[1].foo).to eq 'Dr Scott'
            end
          end
        end

        context 'when array is nested deeper' do
          subject(:ros) { described_class.new(deep_hash, recurse_over_arrays: true) }

          let(:deep_hash) { { foo: { blah: blah_list } } }

          it { expect(ros.foo.blah.length).to eq 3 }

          it 'Retains changes across Array lookups' do
            ros.foo.blah[1].foo = 'Dr Scott'
            expect(ros.foo.blah[1].foo).to eq 'Dr Scott'
          end
        end

        context 'when array is in an array' do
          subject(:ros) { described_class.new(haah, recurse_over_arrays: true) }

          let(:haah) { { blah: [blah_list] } }

          it { expect(ros.blah.length).to eq 1 }
          it { expect(ros.blah[0].length).to eq 3 }

          it 'Retains changes across Array lookups' do
            ros.blah[0][1].foo = 'Dr Scott'

            expect(ros.blah[0][1].foo).to eq 'Dr Scott'
          end
        end
      end # when recursing over arrays is enabled

      context 'when recursing over arrays is disabled' do
        subject(:ros) { described_class.new(h) }

        it { expect(ros.blah.length).to eq 3 }
        it { expect(ros.blah[0]).to eq({ foo: '1' }) }
        it { expect(ros.blah[0][:foo]).to eq '1' }
      end # when recursing over arrays is disabled

      describe 'modifying an array and recursing over it' do
        subject(:ros) { described_class.new(h, recurse_over_arrays: true) }

        let(:h) { {} }

        context 'when adding an array with hashes into the tree' do
          before do
            ros.mystery = {}
            ros.mystery.science = [{ theatre: 9000 }]
          end

          it "ROS's it" do
            expect(ros.mystery.science[0].theatre).to eq 9000
          end
        end

        context 'when appending a hash to an array' do
          before do
            ros.mystery = {}
            ros.mystery.science = []
            ros.mystery.science << { theatre: 9000 }
          end

          it "ROS's it" do
            expect(ros.mystery.science[0].theatre).to eq 9000
          end

          specify 'the changes show up in .to_h' do
            expect(ros.to_h).to eq({ mystery: { science: [{ theatre: 9000 }] } })
          end

          specify 'and the new ROS/hash can have new values set' do
            ros.mystery.science[0].gizmoplex = 9000
            expect(ros.mystery.science[0].gizmoplex).to eq 9000
          end
        end

        context 'when assigning a hash to an array' do
          before do
            ros.mystery = {}
            ros.mystery.science = []
            ros.mystery.science[0] = {}
          end

          it 'can have new values be set' do
            ros.mystery.science[0].theatre = 9000
            expect(ros.mystery.science[0].theatre).to eq 9000
          end
        end
      end # modifying an array and then recursing
    end # recursing over arrays

    describe 'nested nil values' do
      let(:h) { { foo: { bar: nil } } }

      it 'returns nil' do
        expect(ros.foo.bar).to be_nil
      end

      it 'returns a hash with the key and a nil value' do
        expect(ros.to_hash).to eq({ foo: { bar: nil } })
      end
    end # nested nil values
  end # recursive behavior
end
# rubocop:enable Security/MarshalLoad
