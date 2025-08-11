require "hokusai"

class Test < Hokusai::Block
  template <<~EOF
  [template]
    virtual
  EOF

  def render(canvas)
    draw do
      rect(canvas.x, canvas.y, canvas.width / 2.0, canvas.height) do |command|
        command.color = Hokusai::Color.new(255, 255, 0)
      end

      rect(canvas.x + canvas.width / 2.0, canvas.y, canvas.width / 2.0, canvas.height) do |command|
        command.color = Hokusai::Color.new(0, 0, 255)
      end

      text("hello world", canvas.x + (canvas.width / 2.0) + 20, canvas.y + 20) do |command|
        command.size = 24
        command.color = Hokusai::Color.new(0, 255, 0)
      end
    end

    yield canvas
  end
end

class App < Hokusai::Block
  style <<~EOF
  [style]
  circleStyle {
    color: rgb(165, 51, 51);
  }
  EOF
  template <<~EOF
  [template]
    test
    circle {
      :radius="20.0"
      ...circleStyle
    }
  EOF

  uses(test: Test, circle: Hokusai::Blocks::Circle)
end

App.mount